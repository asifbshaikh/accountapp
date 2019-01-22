class ReceiptVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def receipt_voucher_number
		# ReceiptVoucherSequence.increment_counter(:receipt_voucher_sequence, self.id)
		self.reload
        (self.receipt_voucher_sequence+1).to_s.rjust(3, '0')
	end

   def increment_counter
    ReceiptVoucherSequence.increment_counter(:receipt_voucher_sequence, self.id)
   end
end
