class AddColumnToPurchaseLineItem < ActiveRecord::Migration
  def change
    add_column :purchase_line_items, :eligibility, :string, :null => true
    add_column :purchase_line_items, :igst, :decimal, :null => true
    add_column :purchase_line_items, :sgst, :decimal, :null => true
    add_column :purchase_line_items, :cgst, :decimal, :null => true
  end
end
