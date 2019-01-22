class CreateDebitNoteSequences < ActiveRecord::Migration
  def change
    create_table :debit_note_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :debit_note_sequence, :default=>0

      t.timestamps
    end
  end
end
