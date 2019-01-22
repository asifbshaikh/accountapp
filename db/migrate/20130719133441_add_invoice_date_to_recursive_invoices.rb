class AddInvoiceDateToRecursiveInvoices < ActiveRecord::Migration
  def self.up
    add_column :recursive_invoices, :invoice_date, :date, :default => Time.zone.now.to_date
  end

  def self.down
    remove_column :recursive_invoices, :invoice_date
  end
end
