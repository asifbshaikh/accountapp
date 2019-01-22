class AddTotalAmountToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :total_amount, :decimal, :precision => 18, :scale => 2, :default => 0
  end
end
