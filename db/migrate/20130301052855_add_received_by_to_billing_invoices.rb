class AddReceivedByToBillingInvoices < ActiveRecord::Migration
  def self.up
    add_column :billing_invoices, :received_by, :string
  end

  def self.down
    remove_column :billing_invoices, :received_by
  end
end
