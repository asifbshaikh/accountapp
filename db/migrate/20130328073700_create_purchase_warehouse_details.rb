class CreatePurchaseWarehouseDetails < ActiveRecord::Migration
  def self.up
    create_table :purchase_warehouse_details do |t|
      t.integer :purchase_line_item_id
      t.integer :warehouse_id
      t.decimal :quantity, :precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_warehouse_details
  end
end
