class AddSettlementExchangeRateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :settlement_exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
