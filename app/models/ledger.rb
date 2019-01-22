class Ledger < ActiveRecord::Base
  belongs_to :account
  belongs_to :corresponding_account, :class_name => 'Account', :foreign_key => :corresponding_account_id
  belongs_to :company
  belongs_to :voucher, :polymorphic => true
  has_one :bank_statement_line_item
  scope :by_branch, lambda{|id|where(:branch_id => id) unless id.blank? }
  scope :ledgers_in_current_year, lambda { |company_id, account_id, sd, ed| where(:company_id => company_id, :account_id => account_id, :transaction_date => sd..ed, :deleted => false) }
  scope  :by_voucher, lambda{ |voucher| where(:voucher_type => voucher) unless voucher.blank?}
  scope :by_date_range, lambda { |start_date, end_date| where(:transaction_date=>start_date..end_date, :deleted=>false)}
  scope :by_account, lambda { |account| where(:account_id=>account) unless account.blank? }
  scope :by_transaction_date_greater_than_or_equal_to, lambda { |end_date| where("transaction_date >=?", end_date) unless end_date.blank? }
  scope :sales_vouchers, where(:voucher_type => ['Invoice', 'InvoiceReturn'], :deleted => false)
  scope :purchase_vouchers, where(:voucher_type => ['Purchase', 'PurchaseReturn'], :deleted=> false)
  scope :other_vouchers, where("voucher_type not in ('Invoice', 'InvoiceReturn','Purchase', 'PurchaseReturn') and deleted= 0")

  def get_curresponding_product
    product = voucher.get_product(account_id)
    name = product.name unless product.blank?
    name = "<i>#{voucher_type} voucher</i>".html_safe unless !product.blank?
    name
  end

  class << self

    # Returns an Array of total invoice amounts for each day in the given date range.
    #
    # Example
    # Ledger.daily_income_amounts(company, '01-03-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the invoice total amount for '01-03-2015' and so on.
    # Total will be Zero if there are no invoices for a given date.
    # def daily_income_amounts(company, start_date, end_date, user)
    #   daily_incomes = Ledger.select("transaction_date, sum(debit) as total")
    #     .where(:company_id=> company.id, :voucher_type=>'Invoice', :transaction_date=> start_date..end_date, :branch_id=> user.branch_id)
    #     .group("transaction_date")
    #   #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
    #   daily_hash = Hash[daily_incomes.map {|ledger| [ledger.transaction_date, ledger.total]}]
    #   #
    #   daily_invoice_totals = Array.new
    #   # code to add entries for dates that don't have any invoices
    #   start_date.upto(end_date) do |date|
    #       daily_invoice_totals.push(daily_hash[date].blank? ? 0 : daily_hash[date])
    #   end
    #   daily_invoice_totals
    # end

    # Returns an Array of total invoice amounts for each month in the given date range.
    #
    # Example
    # Ledger.monthly_income_amounts(company, '01-01-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the invoice total amount for '01-2015' and so on.
    # Total will be Zero if there are no invoices for a given month.
    # def monthly_income_amounts(company, start_date, end_date, user)
    #   monthly_incomes = Ledger.select("DATE_FORMAT(transaction_date,'%m-%y') as month, sum(debit) as total")
    #     .where(:company_id=> company.id, :voucher_type=>'Invoice', :transaction_date=> start_date..end_date, :branch_id=> user.branch_id)
    #     .group("month(transaction_date)")
    #   #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
    #   monthly_hash = Hash[monthly_incomes.map {|ledger| [ledger.month, ledger.total]}]
    #   date_range = start_date..end_date
    #   date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
    #   date_months = date_months.map {|d| d.strftime "%m-%y" }
    #   monthly_invoice_totals = Array.new

    #   # code to add entries for dates that don't have any invoices
    #   date_months.each do |date|
    #     monthly_invoice_totals.push(monthly_hash[date].blank? ? 0 : monthly_hash[date])
    #   end
    #   monthly_invoice_totals
    # end


    # Returns an Array of total expense amounts for each day in the given date range.
    # The expenses include both Purchase accounts and expense accounts
    # Example
    # Ledger.daily_expense_amounts(company, '01-03-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the expense total amount for '01-03-2015' and so on.
    # Total will be Zero if there are no expenses for a given date.
    def daily_expense_amounts(company, start_date, end_date, user)
      daily_expenses = Ledger.select("transaction_date, sum(credit) as total")
        .where(:company_id=> company.id, :voucher_type=>["Expense", "Purchase"], :transaction_date=> start_date..end_date, :branch_id=> user.branch_id)
        .group("transaction_date")
      #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
      daily_hash = Hash[daily_expenses.map {|ledger| [ledger.transaction_date, ledger.total]}]
      #
      daily_expense_totals = Array.new
      # code to add entries for dates that don't have any expenses
      start_date.upto(end_date) do |date|
          daily_expense_totals.push(daily_hash[date].blank? ? 0 : daily_hash[date])
      end
      daily_expense_totals
    end



    # Returns an Array of total expenses amounts for each month in the given date range.
    #
    # Example
    # Ledger.monthly_expense_amounts(company, '01-01-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the expenses total amount for '01-2015' and so on.
    # Total will be Zero if there are no expensess for a given month.
    def monthly_expense_amounts(company, start_date, end_date, user)
      monthly_expenses = Ledger.select("DATE_FORMAT(transaction_date,'%m-%y') as month, sum(credit) as total")
        .where(:company_id=> company.id, :voucher_type=>["Expense", "Purchase"], :transaction_date=> start_date..end_date, :branch_id=> user.branch_id)
        .group("month(transaction_date)")
      #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
      monthly_hash = Hash[monthly_expenses.map {|ledger| [ledger.month, ledger.total]}]
      date_range = start_date..end_date
      date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
      date_months = date_months.map {|d| d.strftime "%m-%y" }
      monthly_expense_totals = Array.new

      # code to add entries for dates that don't have any invoices
      date_months.each do |date|
        monthly_expense_totals.push(monthly_hash[date].blank? ? 0 : monthly_hash[date])
      end
      monthly_expense_totals
    end


    #[FIXME] This method will become obsolete. Check and remove
    def total_monthly_income(company, user)
      get_ledgers_in_range(["Invoice"], company, user, Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date).sum(:debit)
    end

    #[FIXME] This method will become obsolete. Check and remove
    def total_monthly_expense(company, user)
      get_ledgers_in_range(["Expense", "Purchase"], company, user, Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date).sum(:credit)
    end

    #[FIXME] This method will become obsolete. Check and remove
    def get_array_of_monthly_income_amount(company, user)
      get_array_of(["Invoice"], company, user, Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date)
    end

    #[FIXME] This method will become obsolete. Check and remove
    def get_array_of_monthly_expense_amount(company, user)
      get_array_of(["Expense", "Purchase"], company, user, Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date)
    end

    #[FIXME] This method will become obsolete. Check and remove
    def get_array_of(voucher_types, company, user, start_date, end_date)
      amount_array=[]
      (start_date..end_date).each do |date|
        amount_array<<Ledger.where(:company_id=>company.id, :voucher_type=>voucher_types, :transaction_date=>date, :branch_id=>user.branch_id).sum(:debit)
      end
      amount_array
    end

    def get_ledgers_in_range(voucher_types, company, user, start_date, end_date)
      Ledger.where(:company_id=>company.id, :voucher_type=>voucher_types, :transaction_date=>start_date..end_date, :branch_id=>user.branch_id)
    end

    def generate_secure_random
      Time.now.to_i.to_s+SecureRandom.hex(4)
    end

    def find_matching_transactions(company_id,account_id,amount)
      self.where("(company_id = ? AND account_id = ? AND (credit = ? OR  debit = ?) AND reconcilation_status = ? )",company_id,account_id,amount.to_f,amount.to_f,false)
    end

    def get_tax_amount(company, account, fyr)
      ledgers = Ledger.ledgers_in_current_year(company,account, fyr.start_date, fyr.end_date)
      amt = 0
      ledgers.each do |led|
        if led.voucher_type == 'Purchase'
          amt += led.debit
        elsif led.voucher_type == "Invoice"
          amt += led.credit
        end
      end
      amt
    end

    def new_debit_ledger(account_id, company_id, tx_date, amt, voucher_no, user_id, desc, branch_id, correlate, corresponding_account_id)
      ledger = Ledger.new(
        :account_id => account_id,
        :company_id => company_id,
        :transaction_date => tx_date,
        :debit => amt,
        :voucher_number => voucher_no,
        :created_by => user_id,
        :deleted => false,
        :description => desc,
        :branch_id => branch_id,
        :correlate=>correlate,
        :corresponding_account_id => corresponding_account_id
      )
    end

    def new_gst_debit_ledger(account_id, company_id, tx_date, amt, voucher_no, user_id, branch_id, correlate, corresponding_account_id)
      ledger = Ledger.new(
        :account_id => account_id,
        :company_id => company_id,
        :transaction_date => tx_date,
        :debit => amt,
        :voucher_number => voucher_no,
        :created_by => user_id,
        :deleted => false,
        :branch_id => branch_id,
        :correlate=>correlate,
        :corresponding_account_id => corresponding_account_id
      )
    end

    def new_credit_ledger(account_id, company_id, tx_date, amt, voucher_no, user_id, desc, branch_id, correlate, corresponding_account_id)
      ledger = Ledger.new(
        :account_id => account_id,
        :company_id => company_id,
        :transaction_date => tx_date,
        :credit => amt,
        :voucher_number => voucher_no,
        :created_by => user_id,
        :deleted => false,
        :description => desc,
        :branch_id => branch_id,
        :correlate=>correlate,
        :corresponding_account_id => corresponding_account_id
      )
    end

    def new_gst_credit_ledger(account_id, company_id, tx_date, amt, voucher_no, user_id, branch_id, correlate, corresponding_account_id)
      ledger = Ledger.new(
        :account_id => account_id,
        :company_id => company_id,
        :transaction_date => tx_date,
        :credit => amt,
        :voucher_number => voucher_no,
        :created_by => user_id,
        :deleted => false,
        :branch_id => branch_id,
        :correlate=>correlate,
        :corresponding_account_id => corresponding_account_id
      )
    end

    def get_record(start_date, end_date, branch_id, current_financial_year, user, account)

      begin
        ledgers=Ledger.includes(:corresponding_account).includes(:voucher).order(:transaction_date).ledgers_in_current_year(account.company_id, account, start_date, end_date)
        ledgers=ledgers.by_branch(branch_id) unless user.owner? && branch_id.blank?
      rescue Exception => e
        ledgers = nil
        logger.error "Error in processing #{e}"
        raise e
      end
      ledgers
    end

    def get_cash_book_records(company, user, account, start_date, end_date, branch_id)
      ledgers=company.ledgers.includes(:voucher).includes(:corresponding_account).order("transaction_date DESC").by_account(account.id).by_date_range(start_date, end_date)
      ledgers=ledgers.by_branch(branch_id) unless user.owner? && branch_id.blank?
      ledgers
    end

    def get_gl_record(params, current_financial_year, user, account)
      begin
        start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
        end_date = params[:end_date].blank? ? current_financial_year.end_date : params[:end_date].to_date
        branch_id = params[:branch_id].blank? ? user.branch_id : params[:branch_id].to_i
        ledgers = Ledger.order(:transaction_date).by_branch(branch_id).ledgers_in_current_year(account.company_id, account, start_date, end_date)
      rescue Exception => e
        logger.error e
        raise e
        ledgers = nil
      end
      ledgers
    end

    def against_voucher(voucher_type, voucher_id, company)
      if voucher_type=="PaymentVoucher"
        payment_voucher = PaymentVoucher.find_by_id_and_company_id(voucher_id, company.id)
        unless payment_voucher.blank?
          voucher = payment_voucher.purchase.purchase_number
        end
      elsif voucher_type == "ReceiptVoucher"
        receipt_voucher = ReceiptVoucher.find_by_id_and_company_id(voucher_id, company.id)
        unless receipt_voucher.blank?
          invoices_receipts = InvoicesReceipt.where(:receipt_voucher_id => receipt_voucher.id)
          voucher_arr = []
          invoices_receipts.each do |receipt|
            voucher = receipt.invoice.invoice_number
             voucher_arr << voucher
          end
             voucher_arr
          end
      end
    end

    def get_daybook_record(params, company, user)
      for_date = params[:for_date].blank? ? Time.zone.now.to_date : params[:for_date].to_date
      branch_id = params[:branch_id].blank? ? user.branch_id : params[:branch_id].to_i
      ledgers = Ledger.by_branch(branch_id).where(:company_id => company,:transaction_date => for_date)
    end

    # def get_receivable(params, current_financial_year, user, account)
    #   ledgers = get_record(params, current_financial_year, user, account)
    #   unless ledgers.blank?
    #     ledgers = ledgers.where(:voucher_type => 'Invoice')
    #   end
    #   ledgers
    # end
    # def get_payable(params, current_financial_year, user, account)
    #   ledgers = get_record(params, current_financial_year, user, account)
    #   unless ledgers.blank?
    #     ledgers = ledgers.where(:voucher_type => 'Purchase')
    #   end
    #   ledgers
    # end

    def current_year_balance(company_id, current_user, account, start_date, end_date, branch_id)
      acc = Account.find_by_id_and_company_id(account, company_id)
      financial_year=FinancialYear.where("company_id=? and start_date<? and end_date>=?", acc.company_id, end_date, end_date).first
      opening_balance = acc.get_opening_balance(current_user, acc.company_id, financial_year, start_date, branch_id)
      current_year_transactions = Ledger.get_current_year_transactions(company_id, current_user, account, start_date, end_date, branch_id)
      opening_balance + current_year_transactions
    end

    def get_current_year_transactions(company_id, current_user, account, start_date, end_date, branch_id)
      ledgers = ledgers_in_current_year(company_id, account, start_date, end_date)
      ledgers = ledgers.by_branch(branch_id) unless current_user.owner? && branch_id.blank?

      debit_amount = ledgers.sum(:debit)
      credit_amount = ledgers.sum(:credit)
      if credit_amount.blank?
        credit_amount =0.0
      end
      if debit_amount.blank?
        debit_amount=0.0
      end
      total = debit_amount - credit_amount
    end

    def find_all_by_voucher_type_and_company_id(voucher_type, company_id)
      accounts = Account.find_all_by_company_id(company_id)
      led = []
      for account in accounts
        ledgers = Ledger.find_all_by_account_id(account)
        for ledger in ledgers
          if ledger.voucher_type == voucher_type
            led << ledger
          end
        end
      end
      led
    end

  end

  def corresponding_ledger_entries
    condition = "company_id=#{company_id} and voucher_type='#{voucher_type}' and voucher_id=#{voucher_id} and voucher_number='#{voucher_number}' and id !=#{id} and "
    if correlate.blank?
      if debit==0 && credit==0
        condition +="debit=0.0 and credit=0.0"
      elsif debit == 0
        condition +="debit=#{credit}"
      else
        condition +="credit=#{debit}"
      end
    else
      condition+="correlate='#{correlate}'"
    end
    Ledger.where(condition)
  end


  # This method retrieves the correct account object for a given ledger entry
  def retrieve_corresponding_account
    account = nil
    if corresponding_account_id.blank? || corresponding_account_id == 0
      entries = corresponding_ledger_entries
      if !entries.blank?
        account = entries.first.account
      end
    else
      account = corresponding_account
    end
  end

 #[FIXME] Not sure if this condition is required
 def multiple_correlate_ledgers?
  if !correlate.blank?
   Ledger.where(:correlate => self.correlate, :company_id => self.company_id, :voucher_type => self.voucher_type, :voucher_number => self.voucher_number, :transaction_date => self.transaction_date).count > 2
  end
 end

  # def account_name
  #   Account.find(account_id).name
  # end

end
