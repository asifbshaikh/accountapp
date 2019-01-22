class BalanceSheet

  attr_reader :balance_sheet_date
  #balance_sheet_date is the AS ON DATE for balance sheet
  def initialize(company, financial_year, user, balance_sheet_date, branch)
    @company = company
    @user = user
    @balance_sheet_date = balance_sheet_date
    @branch = branch
    @financial_year = FinancialYear.determine_financial_year(@company, @balance_sheet_date)
  end

  # This is the user entered opening balances.
  def total_opening_balance
    @total_opening_balance ||= (Account.total_opening_balance(@company, @balance_sheet_date) + Product.opening_inventory_valuation(@company))
  end

# liability side accounts balance
  def capital_account_balance
  	@capital_account_balance ||= -1*balance("CapitalAccount")
  end

  def reserves_and_surplus_account_balance
    @reserves_and_surplus_account_balance ||= -1 * balance("ReservesAndSurplusAccount")
  end

  def loan_account_balance
    @loan_account_balance ||= -1 * balance("LoanAccount")
  end

  def secured_loan_account_balance
    @secured_load_account_balance ||= -1 * balance("SecuredLoanAccount")
  end

  def unsecured_loan_account_balance
    @unsecured_load_account_balance ||= -1 * balance("UnsecuredLoanAccount")
  end

  def sundry_creditor_account_balance
    @sundry_creditor_balance ||= -1 * balance("SundryCreditor")
  end

  def duties_and_taxes_account_balance
    @duties_and_taxes_account_balance ||= -1 * balance("DutiesAndTaxesAccounts")
  end

  def provision_account_balance
    @provision_account_balance ||= -1 * balance("ProvisionAccount")
  end

  def current_liabilities_account_balance
    @current_liabilities_account_balance ||= -1 * balance("CurrentLiability")
  end

  def total_current_liability
    @total_current_liability ||= (sundry_creditor_account_balance + duties_and_taxes_account_balance + provision_account_balance + current_liabilities_account_balance)
  end

  def total_liabilities
    @total_liabilities || calculate_total_liabilities
  end

  # Assets side account balance
  def fixed_asset_account_balance
    @fixed_asset_account_balance ||= balance("FixedAsset")
  end

  def investment_account_balance
    @investment_account_balance ||= balance("InvestmentAccount")
  end

  #Current asset accounts
  def bank_account_balance
    @bank_account_balance ||= balance("BankAccount")
  end

  def cash_account_balance
    @cash_account_balance ||= balance("CashAccount")
  end

  def sundry_debtor_account_balance
    @sundry_debtor_account_balance ||=balance("SundryDebtor")
  end

  def deposit_account_balance
    @deposit_account_balance ||= balance("DepositAccount")
  end

  def loan_and_advance_account_balance
    @loan_and_advance_account_balance ||= balance("LoansAdvancesAccount")
  end

  def suspense_account_balance
    @suspense_account_balance ||= balance("SuspenseAccount")
  end

  def current_asset_account_balance
    @current_asset_account_balance ||= balance("CurrentAsset")
  end

  def other_current_asset_account_balance
    @other_current_asset_account_balance ||= balance("OtherCurrentAsset")
  end

  def closing_stock_valution
    inventory_valuation
  end

  def inventory_valuation
    @inventory_valuation ||= Product.total_inventory_valuation(@company, @balance_sheet_date)
  end

  def total_other_current_assets
    @total_other_current_assets || (current_asset_account_balance + other_current_asset_account_balance)
  end


  def total_current_assets
    @total_current_assets ||= bank_account_balance + cash_account_balance + inventory_valuation + sundry_debtor_account_balance +  deposit_account_balance + loan_and_advance_account_balance + total_other_current_assets
  end

  def total_assets
    @total_assets ||= calculate_total_assets
  end


  # -----------------
  # this can be come in both side depends on balance dr or cr
  def deferred_tax_account_balance
    @deferred_tax_asset_or_liability_account_balance ||= balance("DeferredTaxAssetOrLiability")
  end


  def profit_and_loss
    @profit_loss ||= ProfitLoss.new(@company, @balance_sheet_date, fetch_oldest_date, @balance_sheet_date)
    @net_profit_loss ||= @profit_loss.profit_and_loss
  end

  #This is used for display if the split of profit and loss section in balance sheet.
  #This value will be the closing profit and loss or the previous financial year
  def opening_profit_loss
    if @financial_year.nil?
      @opening_profit_and_loss = 0
      @opening_profit_loss =0
    else
      @opening_profit_and_loss ||= ProfitLoss.new(@company, @financial_year, fetch_oldest_date, @financial_year.start_date - 1.days)
      @opening_profit_loss ||= @opening_profit_and_loss.profit_and_loss
    end
  end

  def current_profit_loss
    profit_and_loss - opening_profit_loss
  end

  def total_reserves_and_surplus
    reserves_and_surplus_account_balance
  end

  private

    def balance(account_transaction_type)
      Account.balance_by_account_type(@company, @balance_sheet_date, account_transaction_type)
    end

    #this will calculate the total liabities. The exceptional items are
    # 1. If profit__and_loss is > 0 i.e. in profit then add to liabilities
    # 2. If deferred_tax_account_balance is debit then add to liabilities
    def calculate_total_liabilities
      total_liabilities_amount = capital_account_balance + total_reserves_and_surplus + loan_account_balance +
      secured_loan_account_balance + unsecured_loan_account_balance + total_current_liability +
      total_opening_balance
      if deferred_tax_account_balance < 0
        total_liabilities_amount += deferred_tax_account_balance.abs
      end
      if profit_and_loss >=0
        total_liabilities_amount += profit_and_loss
      end
      total_liabilities_amount
    end

    #this will calculate the total liabities. The exceptional items are
    # 1. If profit__and_loss is < 0 i.e. in loss then add to assets
    # 2. If deferred_tax_account_balance is credit then add to assets
    def calculate_total_assets
      total_assets_amount = fixed_asset_account_balance + investment_account_balance +
        total_current_assets + suspense_account_balance
      if deferred_tax_account_balance >= 0
        total_assets_amount += deferred_tax_account_balance
      end
      if profit_and_loss <0
        total_assets_amount += profit_and_loss.abs
      end
      total_assets_amount
    end

    #this method fetches the oldest date from which to calculate the profit and loss range
    # It fetches the oldest ledger entry date. If no ledgers then it fetches the oldest account created date
    def fetch_oldest_date
      oldest_date = @company.oldest_ledger_date
      if oldest_date.blank?
        oldest_date = @company.accounts.minimum(:start_date)
      end
      oldest_date
    end


end
