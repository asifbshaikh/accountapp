class AddProjectIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :project_id, :integer
  end

  def self.down
    remove_column :purchases, :project_id
  end
end
