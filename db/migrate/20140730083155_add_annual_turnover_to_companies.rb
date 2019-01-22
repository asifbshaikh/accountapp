class AddAnnualTurnoverToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :annual_turnover, :integer
  end
end
