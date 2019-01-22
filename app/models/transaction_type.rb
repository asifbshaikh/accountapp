class TransactionType
  #  Bank Accounts, Cash Accounts, Fixed Assets, Loan Accounts, Secured Loan Accounts, Unsecured Loan Accounts,  Sundry Debtors,  Sundry Creditors, Purchase Accounts, Sales Accounts,

  def self.fetch_to_accounts( company_id, transaction_type)
    to_accounts =nil
    if transaction_type == 'purchases'
      to_accounts = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "PurchaseAccount", false)
    elsif transaction_type == 'sales'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["SundryDebtor", "SundryCreditor"], false)
    elsif transaction_type == 'payments'
      to_accounts  = Account.where(:company_id=>company_id, :accountable_type=>["DirectExpenseAccount",
                          "IndirectExpenseAccount","LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount",
                          "UnsecuredLoanAccount","DepositAccount","SuspenseAccount", "CapitalAccount","DutiesAndTaxesAccounts"], :deleted=>false)
      to_accounts = to_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'receipts'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["BankAccount","CashAccount","SecuredLoanAccount","DirectIncomeAccount","IndirectIncomeAccount","OtherCurrentAsset","CurrentLiability"], false)
    elsif transaction_type == 'contra'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount","CashAccount","DirectIncomeAccount","IndirectIncomeAccount"], false)
    elsif transaction_type == 'journal'
      to_accounts  = Account.where(:company_id=>company_id, :accountable_type=>[
                           "FixedAsset","DirectExpenseAccount","DutiesAndTaxesAccounts","IndirectExpenseAccount",
                             "LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount","SundryCreditor",
                            "UnsecuredLoanAccount","DepositAccount","SuspenseAccount","InvestmentAccount",
                           "SundryDebtor","DirectIncomeAccount","IndirectIncomeAccount", "CapitalAccount","OtherCurrentAsset","CurrentLiability","ReservesAndSurplusAccount","DeferredTaxAssetOrLiability" ], :deleted=>false)
      to_accounts=to_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'saccounting'
      to_accounts  = Account.where(:company_id=>company_id, :accountable_type=>[
                           "FixedAsset","DirectExpenseAccount","DutiesAndTaxesAccounts","IndirectExpenseAccount",
                             "LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount","SundryCreditor",
                            "UnsecuredLoanAccount","DepositAccount","SuspenseAccount","InvestmentAccount",
                           "SundryDebtor","DirectIncomeAccount","IndirectIncomeAccount", "CapitalAccount", "BankAccount", "CashAccount","OtherCurrentAsset","CurrentLiability","ReservesAndSurplusAccount","DeferredTaxAssetOrLiability"], :deleted=>false)
      to_accounts=to_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'stock'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["SalesAccount","PurchaseAccount"], false)
    elsif transaction_type == 'bankacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount","SecuredLoanAccount"], false)
    elsif transaction_type == 'tax'
      to_accounts  = Account.where(:company_id=>company_id, :accountable_type=>"DutiesAndTaxesAccounts", :deleted=>false)
      to_accounts=to_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'shipping'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "IndirectExpenseAccount", false)
    elsif transaction_type == 'cashacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "CashAccount", false)
    elsif transaction_type == 'transferacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount","CashAccount","SecuredLoanAccount"], false)
    elsif transaction_type == 'expenseacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["DirectExpenseAccount",  "IndirectExpenseAccount","ProvisionAccount",
                            "PurchaseAccount","SuspenseAccount"], false)
    elsif transaction_type == 'earningacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["IndirectExpenseAccount", "DirectExpenseAccount"], false)
    elsif transaction_type == 'stddeductionacc'
      to_accounts  = Account.where(:company_id=>company_id, :accountable_type=>["DutiesAndTaxesAccounts", "CurrentLiability", "IndirectIncomeAccount"], :deleted=>false)
      to_accounts=to_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'otherdeductionacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["IndirectIncomeAccount", "CurrentLiability"], false)
    elsif transaction_type == 'payrollacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["IndirectExpenseAccount","DutiesAndTaxesAccounts","IndirectIncomeAccount"], false)
     elsif transaction_type == 'payheadacc'
      to_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["IndirectExpenseAccount","DirectExpenseAccount","CurrentLiability"], false)
    end
  end

  def self.fetch_from_accounts( company_id, transaction_type)
    from_accounts =nil
    if transaction_type== 'purchases'
      from_accounts = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["SundryCreditor","SundryDebtor"], false)
    elsif transaction_type == 'sales'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,"SalesAccount", false)
    elsif transaction_type == 'payments'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount", "CashAccount","SecuredLoanAccount","OtherCurrentAsset","CurrentLiability","UnsecuredLoanAccount"], false)
    elsif transaction_type == 'receipts'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["CapitalAccount","DepositAccount","DirectIncomeAccount","IndirectIncomeAccount",
                                        "LoansAdvancesAccount","LoanAccount","SecuredLoanAccount",
                                        "SundryDebtor", "SundryCreditor","SuspenseAccount","UnsecuredLoanAccount"], false)
    elsif transaction_type == 'contra'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount","CashAccount"], false)
    elsif transaction_type == 'transferacc'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["BankAccount","CashAccount","SecuredLoanAccount"], false)
    elsif transaction_type == 'stock'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["SalesAccount","PurchaseAccount"], false)
    elsif transaction_type == 'journal'
      from_accounts  = Account.where(:company_id=>company_id,:accountable_type=>[
                           "FixedAsset","DirectExpenseAccount","DutiesAndTaxesAccounts","IndirectExpenseAccount",
                             "LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount","SundryCreditor",
                            "UnsecuredLoanAccount","DepositAccount","SuspenseAccount","InvestmentAccount",
                           "SundryDebtor","DirectIncomeAccount","IndirectIncomeAccount", "CapitalAccount","OtherCurrentAsset","CurrentLiability","ReservesAndSurplusAccount","DeferredTaxAssetOrLiability" ], :deleted=>false)
      form_accounts = from_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'saccounting'
      from_accounts  = Account.where(:company_id=>company_id,:accountable_type=>[
                           "FixedAsset","DirectExpenseAccount","DutiesAndTaxesAccounts","IndirectExpenseAccount",
                             "LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount","SundryCreditor",
                            "UnsecuredLoanAccount","DepositAccount","SuspenseAccount","InvestmentAccount",
                           "SundryDebtor","DirectIncomeAccount","IndirectIncomeAccount", "CapitalAccount", "BankAccount", "CashAccount","OtherCurrentAsset","CurrentLiability","ReservesAndSurplusAccount","DeferredTaxAssetOrLiability"], :deleted=>false)
      form_accounts = from_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'bankacc'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["BankAccount","SecuredLoanAccount"], false)
    elsif transaction_type == 'tax'
      from_accounts  = Account.where(:company_id=>company_id, :accountable_type=>"DutiesAndTaxesAccounts", :deleted=>false)
      form_accounts = from_accounts.by_end_date(Time.zone.now.to_date)
    elsif transaction_type == 'shipping'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "IndirectExpenseAccount", false)
    elsif transaction_type == 'cashacc'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "CashAccount", false)
    elsif transaction_type == 'expenseacc'
      from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["BankAccount", "CashAccount","SecuredLoanAccount",
            "UnsecuredLoanAccount"], false)
    elsif transaction_type == 'earningacc'
    from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, ["IndirectExpenseAccount", "DirectExpenseAccount"], false)
       elsif transaction_type == 'stddeductionacc'
    from_accounts  = Account.where(:company_id=>company_id, :accountable_type=>"DutiesAndTaxesAccounts", :deleted=>false)
    form_accounts = from_accounts.by_end_date(Time.zone.now.to_date)
   elsif transaction_type == 'otherdeductionacc'
    from_accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id, "IndirectIncomeAccount", false)
    elsif transaction_type == 'payrollacc'
    from_accounts  = Account.where(:company_id=>company_id, :accountable_type=>["IndirectExpenseAccount","DutiesAndTaxesAccounts","IndirectIncomeAccount"], :deleted=>false)
    form_accounts = from_accounts.by_end_date(Time.zone.now.to_date)
  end
  end
end
