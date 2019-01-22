class AddBranchIdToIncomeVouchers < ActiveRecord::Migration
  def self.up
    add_column :income_vouchers, :branch_id, :integer
  end

  def self.down
    remove_column :income_vouchers, :branch_id
  end
end
