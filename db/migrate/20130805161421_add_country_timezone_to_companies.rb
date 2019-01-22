class AddCountryTimezoneToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :country_id, :integer
    add_column :companies, :timezone, :string
  end
end
