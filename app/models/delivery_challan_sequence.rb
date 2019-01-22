class DeliveryChallanSequence < ActiveRecord::Base
belongs_to :company

	def delivery_challan_number
		DeliveryChallanSequence.increment_counter(:delivery_challan_sequence, self.id)
		self.reload
		self.delivery_challan_sequence.to_s.rjust(3, '0')
	end
end
