class AddCustomFieldsToStockReceiptVouchers < ActiveRecord::Migration
  def self.up
    add_column :stock_receipt_vouchers, :custom_field1, :string
    add_column :stock_receipt_vouchers, :custom_field2, :string
    add_column :stock_receipt_vouchers, :custom_field3, :string
  end

  def self.down
    remove_column :stock_receipt_vouchers, :custom_field3
    remove_column :stock_receipt_vouchers, :custom_field2
    remove_column :stock_receipt_vouchers, :custom_field1
  end
end
