class CreateGstrAdvanceReceiptVoucherSequences < ActiveRecord::Migration
  def change
    create_table :gstr_advance_receipt_voucher_sequences do |t|

      t.integer :company_id, :null=>false
      t.integer :gstr_advance_receipt_voucher_sequence, :default=>0

      t.timestamps
   
    end
  end
end
