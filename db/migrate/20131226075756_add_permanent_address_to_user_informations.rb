class AddPermanentAddressToUserInformations < ActiveRecord::Migration
  def change
    add_column :user_informations, :permanent_address, :string
  end
end
