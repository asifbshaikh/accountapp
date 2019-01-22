class StockReceiptVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def stock_receipt_voucher_number
		StockReceiptVoucherSequence.increment_counter(:stock_receipt_voucher_sequence, self.id)
		self.reload
		self.stock_receipt_voucher_sequence.to_s.rjust(3, '0')
	end
end
