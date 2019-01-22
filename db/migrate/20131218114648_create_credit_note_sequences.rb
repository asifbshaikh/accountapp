class CreateCreditNoteSequences < ActiveRecord::Migration
  def change
    create_table :credit_note_sequences do |t|
      t.integer :company_id, :null=> false
      t.integer :credit_note_sequence, :default=>0

      t.timestamps
    end
  end
end
