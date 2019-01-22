class AddCurrencyIdAndExchangeRateToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :currency_id, :integer
    add_column :purchases, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
