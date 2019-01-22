class ChangeInvoiceIdForReceiptVouchers < ActiveRecord::Migration
  def self.up
  	change_column_null :receipt_vouchers, :invoice_id, true
  end

  def self.down
  	change_column_null :receipt_vouchers, :invoice_id, false
  end
end
