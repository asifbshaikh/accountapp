class TransferCashSequence < ActiveRecord::Base
	belongs_to :company

	def transfer_cash_number
		TransferCashSequence.increment_counter(:transfer_cash_sequence, self.id)
		self.reload
		self.transfer_cash_sequence.to_s.rjust(3, '0')
	end
end
