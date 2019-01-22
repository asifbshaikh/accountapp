class AddBranchIdToPurchaseOrder < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :branch_id, :integer
  end

  def self.down
    remove_column :purchase_orders, :branch_id
  end
end
