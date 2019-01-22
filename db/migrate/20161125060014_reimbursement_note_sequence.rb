class ReimbursementNoteSequence < ActiveRecord::Migration
  def up
    create_table :reimbursement_note_sequences do |t|
      t.integer :company_id, :null => false
      t.integer :reimbursement_note_sequence, :default => 0

      t.timestamps
    end
  end

  def down
    drop_table :reimbursement_note_sequences
  end
end
