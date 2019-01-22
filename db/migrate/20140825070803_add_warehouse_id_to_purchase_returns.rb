class AddWarehouseIdToPurchaseReturns < ActiveRecord::Migration
  def change
    add_column :purchase_returns, :warehouse_id, :integer
  end
end
