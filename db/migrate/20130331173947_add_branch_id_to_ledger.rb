class AddBranchIdToLedger < ActiveRecord::Migration
  def self.up
    add_column :ledgers, :branch_id, :integer
  end

  def self.down
    remove_column :ledgers, :branch_id
  end
end
