class AddBranchIdToCreditNote < ActiveRecord::Migration
  def self.up
    add_column :credit_notes, :branch_id, :integer
  end

  def self.down
    remove_column :credit_notes, :branch_id
  end
end
