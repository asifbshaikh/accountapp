class AddCurrencyIdAndExchangeRateToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :currency_id, :integer
    add_column :estimates, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
