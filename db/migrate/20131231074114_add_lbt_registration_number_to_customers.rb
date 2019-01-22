class AddLbtRegistrationNumberToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :lbt_registration_number, :string
  end
end
