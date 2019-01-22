class CreatePayrollExecutionJobs < ActiveRecord::Migration
  def self.up
    create_table :payroll_execution_jobs do |t|
      t.integer :company_id
      t.date :execution_date
      t.boolean :status, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :payroll_execution_jobs
  end
end
