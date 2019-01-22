class AddBranchIdToWorkstreams < ActiveRecord::Migration
  def self.up
    add_column :workstreams, :branch_id, :integer
  end

  def self.down
    remove_column :workstreams, :branch_id
  end
end
