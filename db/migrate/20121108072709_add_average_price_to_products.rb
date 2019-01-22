class AddAveragePriceToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :average_price, :decimal, :default => 0
  end

  def self.down
    remove_column :products, :average_price
  end
end
