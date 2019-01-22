class CreatePurchaseReturnTaxes < ActiveRecord::Migration
  def change
    create_table :purchase_return_taxes do |t|
      t.integer :purchase_return_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end
