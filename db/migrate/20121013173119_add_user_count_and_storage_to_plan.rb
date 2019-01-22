class AddUserCountAndStorageToPlan < ActiveRecord::Migration
  def self.up
    add_column :plans, :user_count, :integer
    add_column :plans, :storage_limit_mb, :decimal
  end

  def self.down
    remove_column :plans, :storage_limit_mb
    remove_column :plans, :user_count
  end
end
