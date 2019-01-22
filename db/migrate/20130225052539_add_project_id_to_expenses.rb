class AddProjectIdToExpenses < ActiveRecord::Migration
  def self.up
    add_column :expenses, :project_id, :integer
  end

  def self.down
    remove_column :expenses, :project_id
  end
end
