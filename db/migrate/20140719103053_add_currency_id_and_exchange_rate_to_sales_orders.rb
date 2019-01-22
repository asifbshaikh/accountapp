class AddCurrencyIdAndExchangeRateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :currency_id, :integer
    add_column :sales_orders, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
