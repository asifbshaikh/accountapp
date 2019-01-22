class AddTimeInvoiceToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :time_invoice, :boolean, :default => false
  end

  def self.down
    remove_column :invoices, :time_invoice
  end
end
