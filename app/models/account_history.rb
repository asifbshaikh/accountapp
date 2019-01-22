class AccountHistory < ActiveRecord::Base
  belongs_to :company
  belongs_to :account
  belongs_to :financial_year
  class << self
    def create_record(owner, company_id, account_id , id)
      financial_year = FinancialYear.find_by_company_id_and_id(company_id, id)
      account = Account.find_by_company_id_and_id(company_id, account_id)
      closing_balance = account.get_closing_balance(owner, company_id, financial_year, financial_year.end_date, owner.branch_id)#Ledger.current_year_balance(nil, account.id, financial_year.start_date, financial_year.end_date) unless account.blank?
      if !financial_year.blank? && !account.blank?
        account_history = AccountHistory.new
        account_history.company_id = company_id
        account_history.account_id = account_id
        account_history.financial_year_id = financial_year.id
        account_history.opening_balance = account.opening_balance
        account_history.closing_balance = closing_balance
        account_history
      end
    end 
  end
  
  def update_record(company, account, fyr)
    account_history = AccountHistory.find_by_company_id_and_account_id_and_financial_year_id(company.id, account.id, fyr.id)
    account_history.update_attributes(:opening_balance => account.opening_balance, :closing_balance=> account.current_balance)
  end
    
end
