class PurchaseSequence < ActiveRecord::Base
	belongs_to :company

	def purchase_number
    self.reload
    self.purchase_sequence.to_s.rjust(3, '0')
    
	end
#This method has been added to fix purchase voucher number sequence issue

	def increment_counter
		PurchaseSequence.increment_counter(:purchase_sequence, self.id)
	end
end
