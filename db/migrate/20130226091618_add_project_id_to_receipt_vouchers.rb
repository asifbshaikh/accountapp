class AddProjectIdToReceiptVouchers < ActiveRecord::Migration
  def self.up
    add_column :receipt_vouchers, :project_id, :integer
  end

  def self.down
    remove_column :receipt_vouchers, :project_id
  end
end
