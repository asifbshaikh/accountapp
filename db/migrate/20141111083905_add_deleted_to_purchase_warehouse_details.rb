class AddDeletedToPurchaseWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :purchase_warehouse_details, :deleted, :boolean, :default=>false
  end
end
