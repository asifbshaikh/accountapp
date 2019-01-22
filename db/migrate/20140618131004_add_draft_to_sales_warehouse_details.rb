class AddDraftToSalesWarehouseDetails < ActiveRecord::Migration
  def change
    add_column :sales_warehouse_details, :draft, :boolean, :default=>0
  end
end
