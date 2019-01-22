class ChangeColumnToStockReceiptVouchers < ActiveRecord::Migration
  def self.up
    change_column_null :stock_receipt_vouchers, :received_by,  true
  end

  def self.down
    change_column_null :stock_receipt_vouchers, :received_by, false
  end
end
