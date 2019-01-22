class AddAdvancedAndAllocatedToPaymentVouchers < ActiveRecord::Migration
  def change
    add_column :payment_vouchers, :advanced, :boolean, :default=>false
    add_column :payment_vouchers, :allocated, :boolean
  end
end
