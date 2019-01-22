class AddPurchaseIdToStockReceiptVoucher < ActiveRecord::Migration
  def change
    add_column :stock_receipt_vouchers, :purchase_id, :integer
  end
end
