class AddSoInvoiceToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :so_invoice, :integer, :default => 0
  end
end
