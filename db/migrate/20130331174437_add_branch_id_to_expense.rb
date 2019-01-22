class AddBranchIdToExpense < ActiveRecord::Migration
  def self.up
    add_column :expenses, :branch_id, :integer
  end

  def self.down
    remove_column :expenses, :branch_id
  end
end
