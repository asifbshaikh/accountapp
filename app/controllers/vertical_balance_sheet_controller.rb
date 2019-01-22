class VerticalBalanceSheetController < ApplicationController
  def index
    @menu = "Final Accounts"
    @page_name = "Vertical Balance Sheet"
    @total_inventories = 0
    @capital_accounts = @company.get_accounts_of('Capital Accounts')
    @total_capital_amount = FinalAccount.total_balance(@capital_accounts)

    @loan_accounts = @company.get_accounts_of('Loan Accounts')
    @total_loan_amount = FinalAccount.total_balance(@loan_accounts)

    @secured_loan_accounts = @company.get_accounts_of('Secured Loan Accounts')
    @total_secured_loan_amount = FinalAccount.total_balance(@secured_loan_accounts)

    @unsecured_loan_accounts = @company.get_accounts_of('Unsecured Loan Accounts')
    @total_unsecured_loan_amount = FinalAccount.total_balance(@unsecured_loan_accounts)

    @sundry_creditor_accounts = @company.get_accounts_of('Sundry Creditors')
    @total_sundry_creditor_amount = FinalAccount.total_balance(@sundry_creditor_accounts)

    @duties_and_taxes_accounts = @company.get_accounts_of('Duties and Taxes')
    @total_duties_and_taxes_amount = FinalAccount.total_balance(@duties_and_taxes_accounts)

    @provision_accounts = @company.get_accounts_of('Provisions')
    @total_provision_amount = FinalAccount.total_balance(@provision_accounts)

    @fixed_asset_accounts = @company.get_accounts_of('Fixed Assets')
    @total_fixed_asset_amount = -1*FinalAccount.total_balance(@fixed_asset_accounts)

    @bank_accounts = @company.get_accounts_of('Bank Accounts')
    @total_bank_amount = -1*FinalAccount.total_balance(@bank_accounts)

    @cash_accounts = @company.get_accounts_of('Cash Accounts')
    @total_cash_amount = -1*FinalAccount.total_balance(@cash_accounts)

    @sundry_debtor_accounts = @company.get_accounts_of('Sundry Debtors')
    @total_sundry_debtor_amount = -1*FinalAccount.total_balance(@sundry_debtor_accounts)

    @loan_and_advance_accounts = @company.get_accounts_of('Loans and advances')
    @total_loan_and_advance_amount = -1*FinalAccount.total_balance(@loan_and_advance_accounts)

    @deposit_accounts = @company.get_accounts_of('Deposits')
    @total_deposit_amount = -1*FinalAccount.total_balance(@deposit_accounts)

    @suspense_accounts = @company.get_accounts_of('Suspense Accounts')
    @total_suspense_amount = FinalAccount.total_balance(@suspense_accounts)

    #@investment_accounts = Account.find_all_by_account_head_id(@account_heads[13])
    #@total_investment_amount = FinalAccount.total_balance(@investment_accounts)

    @total_investment_amount = 0
    @nett_profit = @company.get_net_profit
    @total_liabilities = 0
    @total_assets = 0
    if @total_suspense_amount > 0
    @total_liabilities = @total_capital_amount + @total_loan_amount + @total_secured_loan_amount+ @total_unsecured_loan_amount+ @total_sundry_creditor_amount + @total_duties_and_taxes_amount + @total_provision_amount + @total_suspense_amount + @nett_profit
    @total_assets = @total_fixed_asset_amount + @total_investment_amount + @total_bank_amount + @total_cash_amount + @total_sundry_debtor_amount + @total_deposit_amount + @total_loan_and_advance_amount
    else
    @total_liabilities = @total_capital_amount + @total_loan_amount + @total_secured_loan_amount+ @total_unsecured_loan_amount+ @total_sundry_creditor_amount + @total_duties_and_taxes_amount + @total_provision_amount + @nett_profit
    @total_assets = @total_fixed_asset_amount + @total_investment_amount + @total_bank_amount + @total_cash_amount + @total_sundry_debtor_amount + @total_deposit_amount + @total_loan_and_advance_amount + @total_suspense_amount
    end

  end

end