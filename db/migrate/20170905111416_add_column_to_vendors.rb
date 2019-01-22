class AddColumnToVendors < ActiveRecord::Migration
  def change
  	add_column :vendors, :gst_category_id, :integer, :limit => 3
  end
end
