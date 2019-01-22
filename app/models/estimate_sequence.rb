class EstimateSequence < ActiveRecord::Base
	belongs_to :company

	def estimate_number
		EstimateSequence.increment_counter(:estimate_sequence, self.id)
		self.reload
		self.estimate_sequence.to_s.rjust(3, '0')
	end
end
