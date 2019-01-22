class CreateTransferCashSequences < ActiveRecord::Migration
  def change
    create_table :transfer_cash_sequences do |t|
      t.integer :company_id, :null=> false
      t.integer :transfer_cash_sequence, :default=>0

      t.timestamps
    end
  end
end
