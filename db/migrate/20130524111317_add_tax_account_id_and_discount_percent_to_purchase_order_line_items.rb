class AddTaxAccountIdAndDiscountPercentToPurchaseOrderLineItems < ActiveRecord::Migration
  def self.up
    add_column :purchase_order_line_items, :tax_account_id, :integer
    add_column :purchase_order_line_items, :discount_percent, :decimal, :precision => 5, :scale => 2
  end

  def self.down
    remove_column :purchase_order_line_items, :discount_percent
    remove_column :purchase_order_line_items, :tax_account_id
  end
end
