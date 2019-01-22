class AddSellCostToPurchaseAccounts < ActiveRecord::Migration
  def self.up
    add_column :purchase_accounts, :sell_cost, :decimal, :precision => 10, :scale => 2 , :default => 0.0
  end

  def self.down
    remove_column :purchase_accounts, :sell_cost
  end
end
