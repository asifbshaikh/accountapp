class AddTypeToBillingLineItem < ActiveRecord::Migration
  def self.up
    add_column :billing_line_items, :billing_type, :string, :null => false
  end

  def self.down
    remove_column :billing_line_items, :billing_type
  end
end
