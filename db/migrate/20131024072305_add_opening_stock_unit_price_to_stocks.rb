class AddOpeningStockUnitPriceToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :opening_stock_unit_price, :decimal,  :precision => 10, :scale => 2
  end
end
