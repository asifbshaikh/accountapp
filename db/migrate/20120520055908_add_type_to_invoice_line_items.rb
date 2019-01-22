class AddTypeToInvoiceLineItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_line_items, :type, :string
  end

  def self.down
    remove_column :invoice_line_items, :type
  end
end
