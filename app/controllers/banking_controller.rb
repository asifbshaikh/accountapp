class BankingController < ApplicationController

  def index
    
  end

  def new
  	@withdrawal = Withdrawal.new_record(@company)
    @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
    @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
    @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
    
    @deposit = Deposit.new_deposit(@company)
    @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
    @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
    @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
    @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)
    
    @transfer_cash = TransferCash.new_transfer(@company)
    @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
    @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
    @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
    @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
  end

end
