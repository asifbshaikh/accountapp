class PurchaseOrderSequence < ActiveRecord::Base
	belongs_to :company

	def purchase_order_number
     self.reload
     self.purchase_order_sequence.to_s.rjust(3, '0')
	end

    def increment_counter
		PurchaseOrderSequence.increment_counter(:purchase_order_sequence, self.id)
    end

end
