class AddCurrencyIdAndExchangeRateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :currency_id, :integer
    add_column :invoices, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
