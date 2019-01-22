class AddProductBatchIdToStockIssueLineItems < ActiveRecord::Migration
  def change
    add_column :stock_issue_line_items, :product_batch_id, :integer
  end
end
