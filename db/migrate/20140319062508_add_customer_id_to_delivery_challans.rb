class AddCustomerIdToDeliveryChallans < ActiveRecord::Migration
  def change
    add_column :delivery_challans, :customer_id, :integer
    change_column :delivery_challans, :account_id, :integer, :null => true
  end
end
