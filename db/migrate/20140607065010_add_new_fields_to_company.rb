class AddNewFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :facebook_url, :string
    add_column :companies, :twitter_url, :string
    add_column :companies, :linked_in_url, :string
    add_column :companies, :google_plus_url, :string
    add_column :companies, :you_sell, :integer
    add_column :companies, :business_type, :integer
    add_column :companies, :industry, :integer
    add_column :companies, :total_employees, :integer
    add_column :companies, :source, :integer
    add_column :companies, :current_system, :integer
  end
end
