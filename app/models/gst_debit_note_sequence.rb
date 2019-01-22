class GstDebitNoteSequence < ActiveRecord::Base
	belongs_to :company

	def gst_debit_note_number
		# ReceiptVoucherSequence.increment_counter(:receipt_voucher_sequence, self.id)
		self.reload
        (self.gst_debit_note_sequence+1).to_s.rjust(3, '0')
	end

   def increment_counter
    GstDebitNoteSequence.increment_counter(:gst_debit_note_sequence, self.id)
   end
end
