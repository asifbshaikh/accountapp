class AddBranchIdToTransferCashes < ActiveRecord::Migration
  def self.up
    add_column :transfer_cashes, :branch_id, :integer
  end

  def self.down
    remove_column :transfer_cashes, :branch_id
  end
end
