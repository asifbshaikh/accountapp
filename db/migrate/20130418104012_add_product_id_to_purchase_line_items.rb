class AddProductIdToPurchaseLineItems < ActiveRecord::Migration
  def self.up
    add_column :purchase_line_items, :product_id, :integer
  end

  def self.down
    remove_column :purchase_line_items, :product_id
  end
end
