class AddBranchIdToAuditors < ActiveRecord::Migration
  def self.up
    add_column :auditors, :branch_id, :integer
  end

  def self.down
    remove_column :auditors, :branch_id
  end
end
