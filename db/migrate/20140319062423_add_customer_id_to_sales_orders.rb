class AddCustomerIdToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :customer_id, :integer
  end
end
