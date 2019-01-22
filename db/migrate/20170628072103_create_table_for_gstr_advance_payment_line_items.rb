class CreateTableForGstrAdvancePaymentLineItems < ActiveRecord::Migration
  def up
  	create_table :gstr_advance_payment_line_items do |t|
      t.integer :gstr_advance_payment_id
  		t.integer :purchase_id, :null=> false
  		t.integer :product_id, :null=> true
  		t.decimal :quantity,:precision => 10, :scale => 2
  		t.decimal :unit_rate, :precision => 18, :scale => 2
  		t.decimal :discount_percentage, :precision => 4, :scale => 2
  		t.decimal :amount, :precision => 18,  :scale => 2, :null => false, :default => 0
  		t.integer :product_id, :null => false
  		t.text :description
  		t.integer :account_id, :null => true
  		t.decimal :tax_amount,:precision => 18,  :scale => 2, :null => false, :default => 0
      t.string :line_item_type
  		t.timestamps
	end
  end

  def down
  end
end
