class CreateStockWastageLineItems < ActiveRecord::Migration
  def self.up
    create_table :stock_wastage_line_items do |t|
      t.integer :stock_wastage_voucher_id, :null => false
      t.integer :product_id, :null => false
      t.decimal :quantity, :precision => 10, :scale => 2
      t.text :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :stock_wastage_line_items
  end
end
