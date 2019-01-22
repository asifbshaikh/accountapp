class AddBranchIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :branch_id, :integer
  end

  def self.down
    remove_column :products, :branch_id
  end
end
