class AddAdvancedAndAllocatedToReceiptVouchers < ActiveRecord::Migration
  def change
    add_column :receipt_vouchers, :advanced, :boolean, :default=> false
    add_column :receipt_vouchers, :allocated, :boolean
  end
end
