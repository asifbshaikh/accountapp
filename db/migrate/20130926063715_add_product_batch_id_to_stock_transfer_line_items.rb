class AddProductBatchIdToStockTransferLineItems < ActiveRecord::Migration
  def change
    add_column :stock_transfer_line_items, :product_batch_id, :integer
  end
end
