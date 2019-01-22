class CreateStockReceiptVoucherSequences < ActiveRecord::Migration
  def change
    create_table :stock_receipt_voucher_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :stock_receipt_voucher_sequence, :default=>0

      t.timestamps
    end
  end
end
