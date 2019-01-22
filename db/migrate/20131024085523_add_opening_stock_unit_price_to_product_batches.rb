class AddOpeningStockUnitPriceToProductBatches < ActiveRecord::Migration
  def change
    add_column :product_batches, :opening_stock_unit_price, :decimal, :precision => 18, :scale => 2
  end
end
