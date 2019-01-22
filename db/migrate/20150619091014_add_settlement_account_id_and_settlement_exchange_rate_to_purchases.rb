class AddSettlementAccountIdAndSettlementExchangeRateToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :settlement_account_id, :integer
    add_column :purchases, :settlement_exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
