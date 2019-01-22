class RenamePhoneNoToPrimaryPhoneNoAndAddSecondaryPhoneNoToVendorsAndCustomers < ActiveRecord::Migration
  def up
  	rename_column :customers, :phone_number, :primary_phone_number
  	rename_column :vendors, :phone_number, :primary_phone_number
  	add_column :vendors, :secondary_phone_number, :string
  	add_column :customers, :secondary_phone_number, :string
  end

  def down
  end
end
