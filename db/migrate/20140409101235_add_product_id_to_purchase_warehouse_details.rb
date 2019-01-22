class AddProductIdToPurchaseWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :purchase_warehouse_details, :product_id, :integer
  end
end
