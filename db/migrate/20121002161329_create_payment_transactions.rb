class CreatePaymentTransactions < ActiveRecord::Migration
  def self.up
    create_table :payment_transactions do |t|
      t.integer :company_id
      t.integer :transaction_status
      t.string :transaction_reference

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_transactions
  end
end
