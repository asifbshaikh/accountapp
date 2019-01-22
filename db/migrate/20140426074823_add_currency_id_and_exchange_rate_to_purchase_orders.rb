class AddCurrencyIdAndExchangeRateToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :currency_id, :integer
    add_column :purchase_orders, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
