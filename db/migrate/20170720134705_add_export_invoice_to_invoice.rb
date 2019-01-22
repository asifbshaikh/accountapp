class AddExportInvoiceToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :export_invoice, :boolean, :default => false
  end
end
