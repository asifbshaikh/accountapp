class SalesOrderSequence < ActiveRecord::Base
belongs_to :company

	def sales_order_number
		SalesOrderSequence.increment_counter(:sales_order_sequence, self.id)
		self.reload
		self.sales_order_sequence.to_s.rjust(3, '0')
	end
end
