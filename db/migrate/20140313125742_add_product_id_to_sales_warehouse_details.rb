class AddProductIdToSalesWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :sales_warehouse_details, :product_id, :integer
  end
end
