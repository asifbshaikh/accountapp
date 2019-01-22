class AddBranchIdToWithdrawals < ActiveRecord::Migration
  def self.up
    add_column :withdrawals, :branch_id, :integer
  end

  def self.down
    remove_column :withdrawals, :branch_id
  end
end
