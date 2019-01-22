class CreateStockTransferLineItems < ActiveRecord::Migration
  def change
    create_table :stock_transfer_line_items do |t|
      t.integer :stock_transfer_voucher_id, :null => false
      t.integer :product_id, :null=> false
      t.decimal :available_quantity, :precision => 10, :scale => 2
      t.decimal :transfer_quantity, :precision => 10, :scale => 2, :null=> false
      t.integer :destination_warehouse_id, :null => false

      t.timestamps
    end
  end
end
