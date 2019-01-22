class AddCustomFieldToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :custom_field1, :string
    add_column :invoices, :custom_field2, :string
    add_column :invoices, :custom_field3, :string
  end

  def self.down
    remove_column :invoices, :custom_field3
    remove_column :invoices, :custom_field2
    remove_column :invoices, :custom_field1
  end
end
