class AddColumnsToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :default_value1, :string
    add_column :custom_fields, :default_value2, :string
    add_column :custom_fields, :default_value3, :string
  end
end
