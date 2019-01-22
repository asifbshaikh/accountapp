class AddGstnUsernameToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :gstn_username, :string
  end
end
