class CreateGstDebitNotes < ActiveRecord::Migration
  def up
  	create_table :gst_debit_notes do |t|
  		t.integer :company_id, :null => false
    	t.string :gst_debit_note_number
    	t.datetime :gst_debit_note_date
    	t.decimal :amount, :precision => 18,  :scale => 2, :null => false, :default => 0
	    t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
	    t.integer :created_by, :null => false
	    t.integer :purchase_return_id, :null => false
	    t.integer :status_id, :null => false
      t.integer :branch_id
	    t.timestamps
  	end
  end
end