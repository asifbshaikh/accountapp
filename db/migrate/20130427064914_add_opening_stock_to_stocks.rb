class AddOpeningStockToStocks < ActiveRecord::Migration
  def self.up
    add_column :stocks, :opening_stock, :decimal, :precision => 10, :scale => 2, :default => 0
  end

  def self.down
    remove_column :stocks, :opening_stock
  end
end
