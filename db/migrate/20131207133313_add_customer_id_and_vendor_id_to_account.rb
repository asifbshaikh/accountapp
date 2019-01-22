class AddCustomerIdAndVendorIdToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :customer_id, :integer
    add_column :accounts, :vendor_id, :integer
  end
end
