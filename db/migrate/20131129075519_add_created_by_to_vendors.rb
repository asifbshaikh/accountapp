class AddCreatedByToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :created_by, :integer
  end
end
