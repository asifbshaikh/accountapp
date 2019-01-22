class AddCustomFieldsToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :custom_field1, :string
    add_column :estimates, :custom_field2, :string
    add_column :estimates, :custom_field3, :string
  end
end
