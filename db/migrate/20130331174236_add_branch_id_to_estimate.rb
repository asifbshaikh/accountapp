class AddBranchIdToEstimate < ActiveRecord::Migration
  def self.up
    add_column :estimates, :branch_id, :integer
  end

  def self.down
    remove_column :estimates, :branch_id
  end
end
