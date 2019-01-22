class AddLbtRegistrationNumberToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :lbt_registration_number, :string
  end
end
