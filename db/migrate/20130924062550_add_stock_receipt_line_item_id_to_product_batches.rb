class AddStockReceiptLineItemIdToProductBatches < ActiveRecord::Migration
  def change
    add_column :product_batches, :stock_receipt_line_item_id, :integer
  end
end
