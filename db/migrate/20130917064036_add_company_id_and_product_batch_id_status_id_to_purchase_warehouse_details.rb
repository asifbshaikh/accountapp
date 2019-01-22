class AddCompanyIdAndProductBatchIdStatusIdToPurchaseWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :purchase_warehouse_details, :company_id, :integer
    add_column :purchase_warehouse_details, :product_batch_id, :integer
    add_column :purchase_warehouse_details, :status_id, :boolean, :default => true
  end
end
