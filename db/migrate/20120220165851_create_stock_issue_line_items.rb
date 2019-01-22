class CreateStockIssueLineItems < ActiveRecord::Migration
  def self.up
    create_table :stock_issue_line_items do |t|
      t.integer :stock_issue_voucher_id, :null => false
      t.integer :product_id, :null => false
      t.decimal :quantity, :precision => 10, :scale => 2, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :stock_issue_line_items
  end
end
