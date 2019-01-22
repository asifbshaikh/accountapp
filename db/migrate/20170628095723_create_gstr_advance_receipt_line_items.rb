class CreateGstrAdvanceReceiptLineItems < ActiveRecord::Migration
  def change
create_table :gstr_advance_receipt_line_items do |t|

  		t.integer :gstr_advance_receipt_id, :null=> false
  		t.integer :account_id, :null=> true
  		t.decimal :quantity,:precision => 18, :scale => 4, :null=>true
  		t.decimal :unit_rate,:precision => 18, :scale => 4, :null=>true
  		t.decimal :discount_percentage, :precision => 18, :scale => 4, :null=>true
  		t.decimal :amount, :precision => 18, :scale => 4, :null=>true
  		t.integer :product_id, :null => true
  		t.text :description
  		t.decimal :tax_amount,:precision => 18,  :scale => 2, :null => false, :default => 0
      t.string :line_item_type
  		t.timestamps

	end
  end
end
