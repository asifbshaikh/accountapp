class AddBranchIdToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :branch_id, :integer
  end

  def self.down
    remove_column :payments, :branch_id
  end
end
