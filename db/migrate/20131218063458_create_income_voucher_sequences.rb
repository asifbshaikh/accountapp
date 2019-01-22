class CreateIncomeVoucherSequences < ActiveRecord::Migration
  def change
    create_table :income_voucher_sequences do |t|
      t.integer :company_id, :null => false
      t.integer :income_voucher_sequence, :default=>0

      t.timestamps
    end
  end
end
