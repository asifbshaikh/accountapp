class AddPayrollDetailIdToPayrollExecutionJobs < ActiveRecord::Migration
  def change
    add_column :payroll_execution_jobs, :payroll_detail_id, :integer
  end
end
