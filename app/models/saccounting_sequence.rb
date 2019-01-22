class SaccountingSequence < ActiveRecord::Base
	belongs_to :company

	def saccounting_number
		SaccountingSequence.increment_counter(:saccounting_sequence, self.id)
		self.reload
		self.saccounting_sequence.to_s.rjust(3, '0')
	end
end
