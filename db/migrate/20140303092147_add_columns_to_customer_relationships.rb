class AddColumnsToCustomerRelationships < ActiveRecord::Migration
  def self.up
    add_column :customer_relationships, :activity, :integer
    add_column :customer_relationships, :record_date, :date
    add_column :customer_relationships, :time_spent, :decimal, :precision => 10, :scale => 0
    add_column :customer_relationships, :activity_status, :boolean, :default => false
    add_column :customer_relationships, :next_folloup_time, :string
    add_column :customer_relationships, :next_activity, :integer
    
  end

  def self.down
    remove_column :customer_relationships, :activity
    remove_column :customer_relationships, :record_date
    remove_column :customer_relationships, :time_spent
    remove_column :customer_relationships, :activity_status
    remove_column :customer_relationships, :next_folloup_time
    remove_column :customer_relationships, :next_activity
  end
end
