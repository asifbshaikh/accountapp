class ProfitLoss

  attr_reader :branch, :start_date, :end_date

  def initialize(company, financial_year, start_date, end_date)
    @company = company
    @financial_year=financial_year
    @start_date = start_date
    @end_date = end_date
  end

  #The below old code is kept for trail balance
  class << self
    def get_opening_stock_valuation(company, financial_year, as_on, branch_id)
      Product.opening_balance_as_on(company, financial_year, as_on, branch_id)
    end

  end

	#10-Apr-2016 This calculates the profit and loss for the given period
	def profit_and_loss
		@final_balance ||= (direct_income + indirect_income + inventory_valuation) - (direct_expenses + indirect_expenses + opening_stock_valuation)
	end

  def opening_stock_valuation
    #first we reduce the start date by one day to get the closing inventory balance of the previous day
    valuation_date = @start_date - 1.days
    @opening_stock_valuation ||= Product.total_inventory_valuation(@company, valuation_date)
  end

  def inventory_valuation
    @inventory_valuation ||= Product.total_inventory_valuation(@company, @end_date)
  end


  def direct_expenses
    @direct_expenses ||= balance("DirectExpenseAccount")
  end

  def indirect_expenses
    @indirect_expenses ||= balance("IndirectExpenseAccount")
  end

  def direct_income
    @direct_income ||= -1*balance("DirectIncomeAccount")
  end

  def indirect_income
    @indirect_income ||= -1*balance("IndirectIncomeAccount")
  end

  def total_expenses
    @total_expenses ||= direct_expenses + indirect_expenses + opening_stock_valuation
    if(profit_and_loss >=0)
      @total_expenses += profit_and_loss
    end
    @total_expenses
  end

  def total_income
    @total_income = direct_income + indirect_income + inventory_valuation
    if (profit_and_loss <0)
      @total_income += profit_and_loss.abs
    end
    @total_income
  end

  private

    def balance(account_transaction_type)
      account_balance = Account.balance_by_account_type_in_date_range(@company, @start_date, @end_date, account_transaction_type)
    end
end
