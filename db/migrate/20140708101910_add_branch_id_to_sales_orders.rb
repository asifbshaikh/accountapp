class AddBranchIdToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :branch_id, :integer
  end
end
