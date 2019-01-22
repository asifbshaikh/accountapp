class AddColumnGstPurchaseorderInPurchaseOrder < ActiveRecord::Migration
  def up
  	add_column :purchase_orders, :gst_purchaseorder, :boolean, :default => false
  end

  def down
  end
end
