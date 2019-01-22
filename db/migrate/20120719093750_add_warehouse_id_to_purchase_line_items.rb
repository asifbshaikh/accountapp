class AddWarehouseIdToPurchaseLineItems < ActiveRecord::Migration
  def self.up
    add_column :purchase_line_items, :warehouse_id, :integer
  end

  def self.down
    remove_column :purchase_line_items, :warehouse_id
  end
end
