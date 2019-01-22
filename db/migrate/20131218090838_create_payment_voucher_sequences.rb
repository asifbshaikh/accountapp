class CreatePaymentVoucherSequences < ActiveRecord::Migration
  def change
    create_table :payment_voucher_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :payment_voucher_sequence, :default=>0

      t.timestamps
    end
  end
end
