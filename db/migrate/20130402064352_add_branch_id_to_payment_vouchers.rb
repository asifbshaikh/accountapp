class AddBranchIdToPaymentVouchers < ActiveRecord::Migration
  def self.up
    add_column :payment_vouchers, :branch_id, :integer
  end

  def self.down
    remove_column :payment_vouchers, :branch_id
  end
end
