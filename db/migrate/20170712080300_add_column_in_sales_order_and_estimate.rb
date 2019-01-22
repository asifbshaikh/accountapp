class AddColumnInSalesOrderAndEstimate < ActiveRecord::Migration
  def up
  	add_column :estimates, :gst_estimate, :boolean, :default => false
  	add_column :sales_orders, :gst_salesorder, :boolean, :default => false
  end

  def down
  end
end
