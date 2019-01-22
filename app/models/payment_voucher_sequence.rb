class PaymentVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def payment_voucher_number
		PaymentVoucherSequence.increment_counter(:payment_voucher_sequence, self.id)
		self.reload
		self.payment_voucher_sequence.to_s.rjust(3, '0')
	end
end
