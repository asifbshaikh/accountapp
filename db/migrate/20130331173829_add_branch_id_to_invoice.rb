class AddBranchIdToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :branch_id, :integer
  end

  def self.down
    remove_column :invoices, :branch_id
  end
end
