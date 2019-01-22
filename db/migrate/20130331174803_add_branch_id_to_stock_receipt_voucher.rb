class AddBranchIdToStockReceiptVoucher < ActiveRecord::Migration
  def self.up
    add_column :stock_receipt_vouchers, :branch_id, :integer
  end

  def self.down
    remove_column :stock_receipt_vouchers, :branch_id
  end
end
