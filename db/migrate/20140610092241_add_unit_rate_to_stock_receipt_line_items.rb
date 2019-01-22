class AddUnitRateToStockReceiptLineItems < ActiveRecord::Migration
  def change
    add_column :stock_receipt_line_items, :unit_rate, :decimal, :precision=>18, :scale=>2, :default=>0
  end
end
