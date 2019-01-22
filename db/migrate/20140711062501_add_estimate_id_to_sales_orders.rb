class AddEstimateIdToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :estimate_id, :integer
  end
end
