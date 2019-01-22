class CreateReceiptVoucherSequences < ActiveRecord::Migration
  def change
    create_table :receipt_voucher_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :receipt_voucher_sequence, :default=>0

      t.timestamps
    end
  end
end
