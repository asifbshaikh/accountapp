class AddProductBatchIdToStockWastageLineItems < ActiveRecord::Migration
  def change
    add_column :stock_wastage_line_items, :product_batch_id, :integer
  end
end
