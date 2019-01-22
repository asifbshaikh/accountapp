class AddColumnPlaceOfSupplyInSalesOrders < ActiveRecord::Migration
  def up
  	add_column :sales_orders, :place_of_supply, :string, :limit => 3
  end

  def down
  end
end
