class AddColumnToBillingInvoices < ActiveRecord::Migration
  def self.up
    add_column :billing_invoices, :closed_by, :integer
  end

  def self.down
    remove_column :billing_invoices, :closed_by
  end
end
