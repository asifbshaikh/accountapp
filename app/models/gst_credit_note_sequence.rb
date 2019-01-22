class GstCreditNoteSequence < ActiveRecord::Base
	belongs_to :company

	def gst_credit_note_number
		self.reload
        (self.gst_credit_note_sequence+1).to_s.rjust(3, '0')
	end

   def increment_counter
    GstCreditNoteSequence.increment_counter(:gst_credit_note_sequence, self.id)
   end
end
