class AddNotableIdAndNotableTypeToCustomerRelationships < ActiveRecord::Migration
  def self.up
    add_column :customer_relationships, :notable_id, :integer
    add_column :customer_relationships, :notable_type, :string
  end

  def self.down
    remove_column :customer_relationships, :notable_type
    remove_column :customer_relationships, :notable_id
  end
end
