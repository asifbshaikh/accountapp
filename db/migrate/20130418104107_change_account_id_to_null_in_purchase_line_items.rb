class ChangeAccountIdToNullInPurchaseLineItems < ActiveRecord::Migration
  def self.up
    change_column_null :purchase_line_items, :account_id, true
  end

  def self.down
    change_column_null :purchase_line_item, :account_id, false
  end
end
