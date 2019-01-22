class AddCurrencyIdAndExchangeRateToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :currency_id, :integer
    add_column :expenses, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
