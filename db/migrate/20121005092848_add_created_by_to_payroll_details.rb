class AddCreatedByToPayrollDetails < ActiveRecord::Migration
  def self.up
    add_column :payroll_details, :created_by, :integer
  end

  def self.down
    remove_column :payroll_details, :created_by
  end
end
