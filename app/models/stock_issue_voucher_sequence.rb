class StockIssueVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def stock_issue_voucher_number
		StockIssueVoucherSequence.increment_counter(:stock_issue_voucher_sequence, self.id)
		self.reload
		self.stock_issue_voucher_sequence.to_s.rjust(3, '0')
	end
end
