class AddBranchIdToInvoiceReturns < ActiveRecord::Migration
  def change
    add_column :invoice_returns, :branch_id, :integer
  end
end
