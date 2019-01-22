class WithdrawalSequence < ActiveRecord::Base
	belongs_to :company

	def withdrawal_number
		WithdrawalSequence.increment_counter(:withdrawal_sequence, self.id)
		self.reload
		self.withdrawal_sequence.to_s.rjust(3, '0')
	end
end
