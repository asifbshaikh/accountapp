class AddDiscountPercentToPurchaseLineItems < ActiveRecord::Migration
  def self.up
    add_column :purchase_line_items, :discount_percent, :decimal, :precision => 5, :scale => 2 
  end

  def self.down
    remove_column :purchase_line_items, :discount_percent
  end
end
