class AddPhoneNumberToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :phone_number, :string
  end
end
