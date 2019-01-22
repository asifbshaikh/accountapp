class AddTdsColumnToPaymentVouchers < ActiveRecord::Migration
  def change
    add_column :payment_vouchers, :tds_account_id, :integer
    add_column :payment_vouchers, :tds_amount, :decimal, :precision => 18, :scale => 2, :default => 0 
  end
end
