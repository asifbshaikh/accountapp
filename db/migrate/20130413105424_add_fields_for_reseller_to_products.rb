class AddFieldsForResellerToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :description, :text
    add_column :products, :type, :string
    add_column :products, :purchase_price, :decimal, :precision => 18, :scale => 2, :default => 0
    add_column :products, :sales_price, :decimal, :precision => 18, :scale => 2, :default => 0
    add_column :products, :expense_account_id, :integer
    add_column :products, :income_account_id, :integer
    add_column :products, :reorder_level, :decimal, :precision => 10, :scale => 2, :default => 0
    add_column :products, :inventory, :boolean
  end

  def self.down
    remove_column :products, :inventory
    remove_column :products, :reorder_level
    remove_column :products, :income_account_id
    remove_column :products, :expense_account_id
    remove_column :products, :sales_price
    remove_column :products, :purchase_price
    remove_column :products, :type
    remove_column :products, :description
  end
end
