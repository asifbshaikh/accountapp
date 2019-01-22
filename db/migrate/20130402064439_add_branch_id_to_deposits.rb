class AddBranchIdToDeposits < ActiveRecord::Migration
  def self.up
    add_column :deposits, :branch_id, :integer
  end

  def self.down
    remove_column :deposits, :branch_id
  end
end
