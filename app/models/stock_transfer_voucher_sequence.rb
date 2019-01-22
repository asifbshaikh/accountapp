class StockTransferVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def stock_transfer_voucher_number
		StockTransferVoucherSequence.increment_counter(:stock_transfer_voucher_sequence, self.id)
		self.reload
		self.stock_transfer_voucher_sequence.to_s.rjust(3, '0')
	end
end
