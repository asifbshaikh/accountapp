class ChangeDataTypeForPurchaseOrderLineItemsTax < ActiveRecord::Migration
  def self.up
     change_table :purchase_order_line_items do |t|
      t.change :tax, :boolean
    end
  end

  def self.down
   change_table :purchase_order_line_items do |t|
      t.change :tax, :decimal
    end
  end
end
