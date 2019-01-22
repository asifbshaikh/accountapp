class CreditNoteSequence < ActiveRecord::Base
	belongs_to :company

	def credit_note_number
		CreditNoteSequence.increment_counter(:credit_note_sequence, self.id)
		self.reload
		self.credit_note_sequence.to_s.rjust(3,'0')
	end
end
