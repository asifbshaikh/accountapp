class CreateGstCreditNoteTaxes < ActiveRecord::Migration
  def up
  	create_table :gst_credit_note_taxes do |t|
  	t.integer :gst_credit_note_line_item_id, :null => false
  	t.integer :account_id, :null => false
  	t.timestamps
  end
  end

  def down
  end
end
