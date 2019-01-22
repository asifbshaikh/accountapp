class AddBranchIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :branch_id, :integer
  end

  def self.down
    remove_column :users, :branch_id
  end
end
