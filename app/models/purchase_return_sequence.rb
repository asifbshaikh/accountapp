class PurchaseReturnSequence < ActiveRecord::Base
	belongs_to :company

	def purchase_return_number
		PurchaseReturnSequence.increment_counter(:purchase_return_sequence, self.id)
		self.reload
		self.purchase_return_sequence.to_s.rjust(3, '0')
	end
end
