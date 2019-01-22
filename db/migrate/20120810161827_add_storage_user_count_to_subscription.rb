class AddStorageUserCountToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :allocated_storage_mb, :decimal
    add_column :subscriptions, :utilized_storage_mb, :decimal
    add_column :subscriptions, :allocated_user_count, :integer
    add_column :subscriptions, :utilized_user_count, :integer
  end

  def self.down
    remove_column :subscriptions, :allocated_user_count
    remove_column :subscriptions, :utilized_user_count
    remove_column :subscriptions, :utilized_storage_mb
    remove_column :subscriptions, :allocated_storage_mb
  end
end
