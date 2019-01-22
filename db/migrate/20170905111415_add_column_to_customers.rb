class AddColumnToCustomers < ActiveRecord::Migration
  def change
  	add_column :customers, :gst_category_id, :integer, :limit => 3
  end
end
