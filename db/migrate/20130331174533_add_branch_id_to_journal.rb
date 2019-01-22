class AddBranchIdToJournal < ActiveRecord::Migration
  def self.up
    add_column :journals, :branch_id, :integer
  end

  def self.down
    remove_column :journals, :branch_id
  end
end
