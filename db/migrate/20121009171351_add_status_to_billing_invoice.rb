class AddStatusToBillingInvoice < ActiveRecord::Migration
  def self.up
    add_column :billing_invoices, :status_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :billing_invoices, :status_id
  end
end
