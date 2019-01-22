class AddGatewayFieldsToPaymentTransaction < ActiveRecord::Migration
  def self.up
    add_column :payment_transactions, :issuer_ref_num, :string
    add_column :payment_transactions, :auth_ID_code, :string
    add_column :payment_transactions, :transaction_msg, :string
    add_column :payment_transactions, :gateway_transaction_num, :string
    add_column :payment_transactions, :gateway_transaction_status, :string
    add_column :payment_transactions, :gateway_transaction_ref, :string
  end

  def self.down
    remove_column :payment_transactions, :gateway_transaction_ref
    remove_column :payment_transactions, :gateway_transaction_status
    remove_column :payment_transactions, :gateway_transaction_num
    remove_column :payment_transactions, :transaction_msg
    remove_column :payment_transactions, :auth_ID_code
    remove_column :payment_transactions, :issuer_ref_num
  end
end
