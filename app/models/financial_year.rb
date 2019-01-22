class FinancialYear < ActiveRecord::Base
  belongs_to :company
  belongs_to :year
  has_many :account_histories
  has_many :financial_year_logs
  has_many :stock_histories
  has_many :gstr_ones
  has_many :gstr_twos

  STATUS={true=>"frozen", false=>'unfreeze'}

  #BEGIN CLASS METHODS
  class << self

    #Determines the financial year for the given company and input_date
    # returns nil incase input_date is outside this companies financial year data
    def determine_financial_year(company, input_date)
      financial_year = nil
      company.financial_years.each do |fin_year|
        if input_date.between?(fin_year.start_date, fin_year.end_date)
          financial_year= fin_year
          break
        end
      end
      financial_year
    end

    def check_if_frozen(company, date)
      result=false
      financial_year=FinancialYear.where("company_id=? and start_date<=? and end_date>?", company, date, date).first
      unless financial_year.blank?
        result=financial_year.is_freezed?
      end
      result
    end

    #[FIXME] This method is called from balance sheet and is obsolete
    def get_opening_balance(current_user, company_id, start_date, end_date)
      opening_balance = 0
      financial_year= FinancialYear.find_by_company_id_and_start_date_and_end_date(company_id, start_date, end_date)
      unless financial_year.blank?
        previous_financial_year= financial_year.get_previous_year#FinancialYear.find_by_company_id_and_start_date_and_end_date(company_id, (start_date - 1.years), (end_date - 1.years))
        if previous_financial_year.blank?
          opening_balance = 0
        elsif previous_financial_year.freeze?
          opening_balance = financial_year.opening_balance
        else
          opening_balance = ProfitLoss.get_profit_and_loss(current_user, nil, previous_financial_year, nil)
        end
      end
      opening_balance
    end
  end
  #END CLASS METHODS


  #[FIXME] This method is not called from balance sheet. Can remove if not called from any other reports
  def get_opening_balance_difference(current_user, branch_id)
    total = 0
    # accounts = Account.where("company_id = ? and deleted=false and accountable_type not in (?)", company.id, ["DirectExpenseAccount", "IndirectExpenseAccount", "DirectIncomeAccount", "IndirectIncomeAccount"])
    # accounts=Account.where(:company_id=>company.id, :deleted=>false)
    accounts=Account.where("company_id=? and deleted=false and start_date<=?", company_id, end_date)
    accounts.each do |account|
      total += account.get_opening_balance(current_user, company.id, self, start_date, branch_id)
    end
    total += ProfitLoss.get_opening_stock_valuation(company.id, self, start_date, nil)

    -1*total
  end

  def freez_financial_year
    result=false
    closing_stock_value=0
    opening_stock_value=0
    transaction do
      next_financial_year = get_next_year
      previous_financial_year = get_previous_year
      owner = company.users.first
      nett_profit = ProfitLoss.get_profit_and_loss(owner, nil, self, nil)
      company.accounts.each do |account|
        account_history = AccountHistory.create_record(owner, company.id, account.id, id)
        if account_history.save
          if Account.account_type.include?(account.accountable_type)
            account.update_attributes(:opening_balance => 0)
          else
            account.update_attributes(:opening_balance => account_history.closing_balance)
          end
        end
      end

      products = Product.where(:company_id => company.id, :inventory => true)
      products.each do |product|
        total_quantity=product.closing_stock_quantity(self, end_date, nil)
        total_quantity+=product.stocks.sum(:opening_stock)

        total_amount=product.closing_value(self, nil)
        closing_stock_value+=total_amount
        opening_stock_value+=product.get_opening_stock_amount

        avg_unit_cost=0
        avg_unit_cost=total_amount.to_f/total_quantity.to_f if total_amount>0 && total_quantity>0
        product.stocks.each do |stock|
          stock_history=StockHistory.create_history(stock, self)
          quantity=stock.get_closing_quantity(self)
          stock.update_attributes(:opening_stock=>quantity, :opening_stock_unit_price=>avg_unit_cost)
        end
      end
      if previous_financial_year.blank?
        update_attributes(:freeze=> 1, :closing_balance=> (nett_profit), :closing_stock_valuation=> closing_stock_value, :opening_stock_valuation=>opening_stock_value)
      else
        update_attributes(:freeze=> 1, :closing_balance=> (nett_profit), :closing_stock_valuation=> closing_stock_value)
      end
      if !next_financial_year.blank? && !closing_balance.blank?
        next_financial_year.update_attributes(:opening_balance=>closing_balance, :opening_stock_valuation=>closing_stock_valuation)
      end
      result=true
    end
    result
  end

  def unfreeze
    result = false
    transaction do
      account_histories.each do |account_history|
        account_history.account.update_attributes(:opening_balance => account_history.opening_balance)
      end
      AccountHistory.delete(account_histories)

      stock_histories.each do |stock_history|
        stock_history.stock.update_attributes(:opening_stock=>stock_history.opening_stock, :opening_stock_unit_price=>stock_history.opening_stock_value)
      end
      StockHistory.delete(stock_histories)

      update_attributes(:freeze => false, :closing_balance => nil, :closing_stock_valuation=>0)
      next_year = get_next_year
      next_year.update_attributes(:opening_balance => 0.00, :opening_stock_valuation=>0) unless next_year.blank?
      result=true
    end
    result
  end

  def get_first_date
    financial_years = company.financial_years.order("start_date ASC").first.start_date
  end

  def get_next_year
    FinancialYear.find_by_company_id_and_start_date_and_end_date(company_id, (start_date + 1.years), (end_date + 1.years))
  end

  def get_previous_year
    FinancialYear.find_by_company_id_and_start_date_and_end_date(company_id, (start_date - 1.years), (end_date - 1.years))
  end
  def is_freezed?
    freeze?
  end

  def register_user_action(remote_ip, action, activity, user)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " financial year #{year.name} was #{activity}", action, nil)
  end


  def get_period
    if start_date.year == end_date.year
      "FY#{start_date.strftime('%Y')}"
    else
      "#{start_date.strftime('%Y')}-#{end_date.strftime('%y')}"
    end
  end

  def update_period(month)
    this_year = Time.zone.now.year
    tmp_year = Time.zone.now.strftime("%y").to_i
    sd = nil
    ed = nil
    if month.to_i > Time.zone.now.month
      sd = Date.new((this_year - 1), month.to_i, 01 )
      ed = Date.new(this_year, (sd + 11.months).month, 01).end_of_month
    else
      sd = Date.new(this_year, month.to_i, 01)
      unless month.to_i == 1
        this_year += 1
        tmp_year += 1
      end
      ed = Date.new(this_year, (sd + 11.months).month, 01).end_of_month
    end
    year = Year.find_by_name("FY"+tmp_year.to_s)
    year = Year.create(:name => "FY"+tmp_year.to_s) if year.blank?
    update_attributes(:start_date => sd, :end_date => ed, :year_id => year.id)
  end
end
