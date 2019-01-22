class CreateInvoicesReceipts < ActiveRecord::Migration
  def change
    create_table :invoices_receipts do |t|
      t.integer :receipt_voucher_id
      t.integer :invoice_id
      t.decimal :amount, :precision => 18, :scale => 2, :default =>0
      t.decimal :tds_amount, :precision => 18, :scale => 2, :default =>0

      t.timestamps
    end
  end
end
