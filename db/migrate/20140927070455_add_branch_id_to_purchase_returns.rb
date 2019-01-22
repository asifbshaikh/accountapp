class AddBranchIdToPurchaseReturns < ActiveRecord::Migration
  def change
    add_column :purchase_returns, :branch_id, :integer
  end
end
