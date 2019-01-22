class AddColumnAccountIdToSalaryComputationResult < ActiveRecord::Migration
  def change
    add_column :salary_computation_results, :account_id, :integer, :null => false
  end
end
