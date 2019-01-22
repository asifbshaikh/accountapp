class AddSubscriptionTypeToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :subscription_type, :boolean, :default => true
  end

  def self.down
    remove_column :companies, :subscription_type
  end
end
