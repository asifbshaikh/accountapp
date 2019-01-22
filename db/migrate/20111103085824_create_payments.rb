class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.date :payment_date
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :payment_mode
      t.integer :cheque_number
      t.date :cheque_date
      t.string :bank 
      t.string :branch
      t.integer :transaction_id 
      t.date :card_transaction_date 
      t.string :type_of_credit_card
      t.string :card_number      
      t.integer :from_account_id
      t.integer :paid_to_account_id
      t.string :bill_ref
      t.string :description
      t.integer :ledger_id
      t.string :voucher_number
      t.integer :company_id
      t.integer :created_by

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
