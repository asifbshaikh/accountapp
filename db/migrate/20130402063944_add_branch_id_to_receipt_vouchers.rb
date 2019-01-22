class AddBranchIdToReceiptVouchers < ActiveRecord::Migration
  def self.up
    add_column :receipt_vouchers, :branch_id, :integer
  end

  def self.down
    remove_column :receipt_vouchers, :branch_id
  end
end
