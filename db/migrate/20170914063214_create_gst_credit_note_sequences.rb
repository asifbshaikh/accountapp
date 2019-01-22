class CreateGstCreditNoteSequences < ActiveRecord::Migration
  def up
  	 create_table :gst_credit_note_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :gst_credit_note_sequence, :default=>0
	  t.timestamps
  end
  end

  def down
  end
end
