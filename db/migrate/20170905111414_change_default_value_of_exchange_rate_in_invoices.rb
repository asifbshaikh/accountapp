class ChangeDefaultValueOfExchangeRateInInvoices < ActiveRecord::Migration
  def up
  	change_column :invoices, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 1
  end

  def down
  end
end
