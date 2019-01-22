class DebitNoteSequence < ActiveRecord::Base
	belongs_to :company

	def debit_note_number
		DebitNoteSequence.increment_counter(:debit_note_sequence, self.id)
		self.reload
		self.debit_note_sequence.to_s.rjust(3, '0')
	end
end
