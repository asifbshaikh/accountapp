class AddAccountIdToPayrollExecutionJobs < ActiveRecord::Migration
  def self.up
    add_column :payroll_execution_jobs, :account_id, :integer
  end

  def self.down
   remove_column :payroll_execution_jobs, :account_id
  end
end
