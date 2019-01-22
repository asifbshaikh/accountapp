 class GstrAdvanceReceiptHistories < ActiveRecord::Migration
 def change
   	create_table :gstr_advance_receipt_histories do |t|
   		t.integer :gstr_advance_receipt_id
   		t.integer :company_id
   		t.text :description
   		t.integer :to_account_id
   		t.datetime :received_date
   		t.timestamps
   	end
   end

#   def down
#   end
 end
