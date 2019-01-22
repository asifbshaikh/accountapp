class AddLbtRegistrationNumberToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :lbt_registration_number, :string
  end
end
