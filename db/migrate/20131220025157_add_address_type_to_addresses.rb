class AddAddressTypeToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :address_type, :integer, :default => 1
  end
end
