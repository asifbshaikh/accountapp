class AddBillingFieldsToPaymentTransaction < ActiveRecord::Migration
  def self.up
    add_column :payment_transactions, :billing_invoice_id, :integer
    add_column :payment_transactions, :signature, :string
  end

  def self.down
    remove_column :payment_transactions, :signature
    remove_column :payment_transactions, :billing_invoice_id
  end
end
