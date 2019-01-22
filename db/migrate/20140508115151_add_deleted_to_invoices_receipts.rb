class AddDeletedToInvoicesReceipts < ActiveRecord::Migration
  def change
    add_column :invoices_receipts, :deleted, :boolean, :default=>false
  end
end
