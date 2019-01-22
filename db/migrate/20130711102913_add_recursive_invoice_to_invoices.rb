class AddRecursiveInvoiceToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :recursive_invoice, :integer, :default => 0
  end

  def self.down
    remove_column :invoices, :recursive_invoice
  end
end
