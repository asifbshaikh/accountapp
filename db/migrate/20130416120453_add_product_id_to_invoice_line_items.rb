class AddProductIdToInvoiceLineItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_line_items, :product_id, :integer
  end

  def self.down
    remove_column :invoice_line_items, :product_id
  end
end
