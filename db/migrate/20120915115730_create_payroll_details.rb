class CreatePayrollDetails < ActiveRecord::Migration
  def self.up
    create_table :payroll_details do |t|
      t.integer :company_id
      t.date :month
      t.integer :status, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :payroll_details
  end
end
