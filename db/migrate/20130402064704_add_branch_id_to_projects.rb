class AddBranchIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :branch_id, :integer
  end

  def self.down
    remove_column :projects, :branch_id
  end
end
