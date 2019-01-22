class StockWastageVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def stock_wastage_voucher_number
		StockWastageVoucherSequence.increment_counter(:stock_wastage_voucher_sequence, self.id)
		self.reload
		self.stock_wastage_voucher_sequence.to_s.rjust(3, '0')
	end
end
