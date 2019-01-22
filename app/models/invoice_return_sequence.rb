class InvoiceReturnSequence < ActiveRecord::Base
	belongs_to :company

	def invoice_return_number
		InvoiceReturnSequence.increment_counter(:invoice_return_sequence, self.id)
		self.reload
		self.invoice_return_sequence.to_s.rjust(3, '0')
	end
end
