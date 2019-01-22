class AddResellerProductToPurchaseAccounts < ActiveRecord::Migration
  def self.up
    add_column :purchase_accounts, :reseller_product, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_accounts, :reseller_product
  end
end
