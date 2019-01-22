class AddDescriptionAndUnitCostToSalesAccounts < ActiveRecord::Migration
  def self.up
    add_column :sales_accounts, :description, :text
    add_column :sales_accounts, :unit_cost, :decimal, :precision => 10, :scale => 2 , :default => 0.0
  end

  def self.down
    remove_column :sales_accounts, :unit_cost
    remove_column :sales_accounts, :description
  end
end
