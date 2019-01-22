class ReimbursementVoucherLineItem < ActiveRecord::Base
	belongs_to :reimbursement_voucher
	has_one :reimbursement_note

	#validations
	validates :payment_amount, :numericality => {:greater_than_or_equal_to => 0.01,
	                          :message => " should not be zero or negative ." }

	validate :ensure_complete_reimbursement

	def ensure_complete_reimbursement
		reimbursement_note = ReimbursementNote.find(reimbursement_note_id)
		errors.add(:payment_amount, " should be equal to amount of Reimbursement Note #{reimbursement_note.reimbursement_note_number}.") unless payment_amount == reimbursement_note.amount
	end

end
