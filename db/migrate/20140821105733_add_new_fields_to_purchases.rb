class AddNewFieldsToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :purchase_order_id, :integer
    add_column :purchases, :tax_inclusive, :boolean, :default => false
  end
end
