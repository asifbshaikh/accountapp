class AddCashFieldsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :cash_invoice, :boolean, :default => false
    add_column :invoices, :cash_customer_name, :string
    add_column :invoices, :cash_customer_mobile, :string
    add_column :invoices, :cash_customer_email, :string
  end

  def self.down
    remove_column :invoices, :cash_customer_email
    remove_column :invoices, :cash_customer_mobile
    remove_column :invoices, :cash_customer_name
    remove_column :invoices, :cash_invoice
  end
end
