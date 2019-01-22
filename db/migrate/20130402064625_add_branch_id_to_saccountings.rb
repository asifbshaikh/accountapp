class AddBranchIdToSaccountings < ActiveRecord::Migration
  def self.up
    add_column :saccountings, :branch_id, :integer
  end

  def self.down
    remove_column :saccountings, :branch_id
  end
end
