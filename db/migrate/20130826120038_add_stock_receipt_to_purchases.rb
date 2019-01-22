class AddStockReceiptToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :stock_receipt, :boolean, :default => true
  end
end
