class AddTanNoToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :tan_no, :string
  end
end
