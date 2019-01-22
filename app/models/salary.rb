class Salary < ActiveRecord::Base
	belongs_to :payhead
	has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :salary_computation_results

  def total_amount
    amount
  end
	def get_product(tax_id)

  end

  def create_ledger_entry(created_by, credit_account_id)
  	txn_date = Time.zone.now.to_date
    random_str = Ledger.generate_secure_random
    voucher_number="SLR"+Time.now.to_i.to_s
  	debit_ledger_entry = Ledger.new_debit_ledger(payhead.account_id, company_id, txn_date, amount,
  		voucher_number, created_by, "created after payroll process", nil, random_str, credit_account_id)

  	credit_ledger_entry = Ledger.new_credit_ledger(credit_account_id,company_id, txn_date,amount,
  		voucher_number, created_by, "created after payroll process", nil, random_str, payhead.account_id)

  	ledgers<<debit_ledger_entry
  	ledgers<<credit_ledger_entry
  end
end
