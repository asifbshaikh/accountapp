class DepositSequence < ActiveRecord::Base
	belongs_to :company

	def deposit_number
		DepositSequence.increment_counter(:deposit_sequence, self.id)
		self.reload
		self.deposit_sequence.to_s.rjust(3,'0')
	end
end
