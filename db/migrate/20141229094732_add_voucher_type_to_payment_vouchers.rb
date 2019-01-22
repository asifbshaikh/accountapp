class AddVoucherTypeToPaymentVouchers < ActiveRecord::Migration
  def change
    add_column :payment_vouchers, :voucher_type, :integer, :default=>0
  end
end
