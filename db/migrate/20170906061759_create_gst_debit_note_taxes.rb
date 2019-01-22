class CreateGstDebitNoteTaxes < ActiveRecord::Migration
 def change
    create_table :gst_debit_note_taxes do |t|
      t.integer :gst_debit_note_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end
