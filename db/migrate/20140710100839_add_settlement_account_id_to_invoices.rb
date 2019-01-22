class AddSettlementAccountIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :settlement_account_id, :integer
  end
end
