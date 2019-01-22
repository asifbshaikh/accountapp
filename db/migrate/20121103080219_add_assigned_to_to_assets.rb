class AddAssignedToToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :assigned_to, :integer
  end

  def self.down
    remove_column :assets, :assigned_to
  end
end
