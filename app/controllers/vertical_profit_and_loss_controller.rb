class VerticalProfitAndLossController < ApplicationController
  def index
    @menu = "Final Accounts"
    @page_name = "Vertical Profit and Loss"

    @purchase_accounts = @company.get_accounts_of('Purchase Accounts')
    @total_purchase_amount = -1*FinalAccount.total_balance(@purchase_accounts)

    @direct_expenses = @company.get_accounts_of('Direct Expenses')
    @total_direct_expence = -1*FinalAccount.total_balance(@direct_expenses)

    @indirect_expenses = @company.get_accounts_of('Indirect Expenses')
    @total_indirect_expence = -1*FinalAccount.total_balance(@indirect_expenses)

    @sale_accounts = @company.get_accounts_of('Sales Accounts')
    @total_sales_amount = FinalAccount.total_balance(@sale_accounts)

    @direct_income_accounts = @company.get_accounts_of('Direct Incomes')
    @total_direct_income_amount = FinalAccount.total_balance(@direct_income_accounts)

    @indirect_income_accounts = @company.get_accounts_of('Indirect Incomes')
    @total_indirect_income_amount = FinalAccount.total_balance(@indirect_income_accounts)
    @opening_stock = 0
    @closing_stock = 0
  end

end
