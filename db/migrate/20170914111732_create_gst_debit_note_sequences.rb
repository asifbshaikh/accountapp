class CreateGstDebitNoteSequences < ActiveRecord::Migration
  def change
  	 create_table :gst_debit_note_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :gst_debit_note_sequence, :default=>0

      t.timestamps
  	end
  end
end
