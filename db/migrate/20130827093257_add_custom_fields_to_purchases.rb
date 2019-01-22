class AddCustomFieldsToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :custom_field1, :string
    add_column :purchases, :custom_field2, :string
    add_column :purchases, :custom_field3, :string
  end
end
