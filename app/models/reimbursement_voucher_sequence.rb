class ReimbursementVoucherSequence < ActiveRecord::Base
  belongs_to :company
  belongs_to :reimbursement_voucher

  def reimbursement_voucher_number
    self.reload
    self.reimbursement_voucher_sequence.to_s.rjust(3, '0')
  end

  def increment_counter
    ReimbursementVoucherSequence.increment_counter(:reimbursement_voucher_sequence, self.id)
  end
end
