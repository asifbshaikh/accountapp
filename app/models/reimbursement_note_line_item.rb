class ReimbursementNoteLineItem < ActiveRecord::Base
	belongs_to :reimbursement_note

	#validations
	validates_presence_of :description, :amount
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
	                          :message => " should not be zero or negative ." }
  def expense_account_name
    Account.find(expense_account_id).name
  end

end
