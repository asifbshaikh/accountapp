class AddSalesAccountIdToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :sales_account_id, :integer
  end

  def self.down
    remove_column :tasks, :sales_account_id
  end
end
