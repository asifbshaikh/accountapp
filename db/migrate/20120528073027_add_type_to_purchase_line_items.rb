class AddTypeToPurchaseLineItems < ActiveRecord::Migration
  def self.up
    add_column :purchase_line_items, :type, :string
  end

  def self.down
    remove_column :purchase_line_items, :type
  end
end
