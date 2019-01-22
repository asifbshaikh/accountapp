class CreateSalesOrderTaxes < ActiveRecord::Migration
  def change
    create_table :sales_order_taxes do |t|
      t.integer :sales_order_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end
