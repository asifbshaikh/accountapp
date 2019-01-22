class AddBranchIdToDebitNote < ActiveRecord::Migration
  def self.up
    add_column :debit_notes, :branch_id, :integer
  end

  def self.down
    remove_column :debit_notes, :branch_id
  end
end
