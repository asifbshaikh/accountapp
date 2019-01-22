class CreatePurchaseOrderTaxes < ActiveRecord::Migration
  def change
    create_table :purchase_order_taxes do |t|
      t.integer :purchase_order_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end
