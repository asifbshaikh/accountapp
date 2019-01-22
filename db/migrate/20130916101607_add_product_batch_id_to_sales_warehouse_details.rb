class AddProductBatchIdToSalesWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :sales_warehouse_details, :product_batch_id, :integer
  end
end
