class AddColumnsToContacts < ActiveRecord::Migration
  def self.up
  	add_column :contacts, :sundry_debtor_id, :integer
  	add_column :contacts, :role, :string, :limit => 50
  	add_column :contacts, :position, :string, :limit => 50
  	add_column :contacts, :previous_company, :string, :limit => 50
  end

  def self.down
  	remove_column :contacts, :sundry_debtor_id
  	remove_column :contacts, :role
  	remove_column :contacts, :position
  	remove_column :contacts, :previous_company
  end
end
