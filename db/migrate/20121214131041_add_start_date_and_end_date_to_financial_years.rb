class AddStartDateAndEndDateToFinancialYears < ActiveRecord::Migration
  def self.up
    add_column :financial_years, :start_date, :date, :null => false
    add_column :financial_years, :end_date, :date, :null => false
  end

  def self.down
    remove_column :financial_years, :end_date
    remove_column :financial_years, :start_date
  end
end
