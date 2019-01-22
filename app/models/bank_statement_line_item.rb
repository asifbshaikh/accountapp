class BankStatementLineItem < ActiveRecord::Base
	belongs_to :bank_statement
  belongs_to :ledger
	attr_accessible	:date, :from_account, :to_account, :amount, :credit_debit_indicator, :description, :account_balance, :status, :company_id, :bank_statement_id,:account_id,:ledger_id,:cheque_reference,:value_date
	validates_presence_of :date
  def get_status
    if amount==0
      ""
    elsif status == 0
      "Unreconciled"
    elsif status == 1
     "Reconciled"
   else
    "Duplicate"
    end    
  end

  def get_credit_debit
    if amount!=0
      if credit_debit_indicator == true
        "Deposit"
       elsif credit_debit_indicator == false
        "Withdraw"
      end 
    else
      "Not a Transaction"
     end   
  end
  
end
