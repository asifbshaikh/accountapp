class AddBranchIdToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :branch_id, :integer
  end

  def self.down
    remove_column :purchases, :branch_id
  end
end
