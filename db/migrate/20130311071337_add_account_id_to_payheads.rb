class AddAccountIdToPayheads < ActiveRecord::Migration
  def self.up
    add_column :payheads, :account_id, :integer, :null => false
  end

  def self.down
    remove_column :payheads, :account_id
  end
end
