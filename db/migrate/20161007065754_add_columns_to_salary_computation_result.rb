class AddColumnsToSalaryComputationResult < ActiveRecord::Migration
  def change
    add_column :salary_computation_results, :payroll_execution_job_id, :integer, :null => false
    add_column :salary_computation_results, :payroll_detail_id, :integer, :null => false
  end
end
