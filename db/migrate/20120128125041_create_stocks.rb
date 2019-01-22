class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.integer :company_id , :null => false
      t.integer :warehouse_id, :null => false
      t.integer :product_id, :null => false
      t.decimal :quantity,  :precision => 10, :scale => 2, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
