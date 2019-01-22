class AddCustomersVendorsToWorkstreams < ActiveRecord::Migration
  def change
    add_column :workstreams, :customer_id, :integer
    add_column :workstreams, :vendor_id, :integer
    add_column :workstreams, :project_id, :integer
  end
end
