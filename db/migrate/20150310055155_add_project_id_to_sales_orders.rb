class AddProjectIdToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :project_id, :integer
  end
end
