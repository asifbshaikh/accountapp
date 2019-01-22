class AddWarehouseIdToInvoiceLineItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_line_items, :warehouse_id, :integer
  end

  def self.down
    remove_column :invoice_line_items, :warehouse_id
  end
end
