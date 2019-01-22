class AddPayrollDateToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :payroll_date, :integer
  end

  def self.down
    remove_column :companies, :payroll_date
  end
end
