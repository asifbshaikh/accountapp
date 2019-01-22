class AddBillableToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :billable, :boolean
  end

  def self.down
    remove_column :tasks, :billable
  end
end
