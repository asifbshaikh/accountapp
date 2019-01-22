class AddInvoiceSuffixToInvoiceSettings < ActiveRecord::Migration
  def self.up
    add_column :invoice_settings, :invoice_suffix, :string, :size => 10, :null => true
  end

  def self.down
    remove_column :invoice_settings, :invoice_suffix
  end
end
