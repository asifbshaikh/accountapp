class AddShippingAddressToCustomerImport < ActiveRecord::Migration
  def change
   # add_column :customer_imports, :shipping_city, :string
   # add_column :customer_imports, :shipping_state, :string, :limit => 100
    add_column :customer_imports, :shipping_country, :string 
    add_column :customer_imports, :shipping_postal_code, :string, :limit => 15
    add_column :customer_imports, :secondary_phone_number, :string, :limit => 25
  end
end
