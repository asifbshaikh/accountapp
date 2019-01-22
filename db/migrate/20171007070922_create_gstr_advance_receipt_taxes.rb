class CreateGstrAdvanceReceiptTaxes < ActiveRecord::Migration
  def up
  	create_table :gstr_advance_receipt_taxes do |t|
       t.integer :gstr_advance_receipt_line_item_id
       t.integer :account_id

       t.timestamps
   end
  end

  def down
  end
end
