class AddPurchaseLineItemIdToPurchaseReturnLineItems < ActiveRecord::Migration
  def change
    add_column :purchase_return_line_items, :purchase_line_item_id, :integer
  end
end
