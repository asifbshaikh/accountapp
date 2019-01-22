class AddClosedByToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :closed_by, :integer
  end

  def self.down
    remove_column :projects, :closed_by
  end
end
