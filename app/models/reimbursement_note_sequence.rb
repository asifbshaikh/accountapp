class ReimbursementNoteSequence < ActiveRecord::Base
  belongs_to :company
  belongs_to :reimbursement_note

  def reimbursement_note_number
    self.reload
    self.reimbursement_note_sequence.to_s.rjust(3, '0')
  end

  def increment_counter
    ReimbursementNoteSequence.increment_counter(:reimbursement_note_sequence, self.id)
  end
end
