class CreateReceiveCashes < ActiveRecord::Migration
  def self.up
    create_table :receive_cashes do |t|
      t.date :received_date
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :receipt_mode
      t.integer :from_account_id
      t.integer :deposit_to_account_id
      t.string :description
      t.binary :send_thank_you_mail
      t.integer :cheque_number
      t.date :cheque_date
      t.string :bank 
      t.string :branch
      t.integer :transaction_id 
      t.date :transaction_date 
      t.string :type_of_credit_card
      t.string :card_number
      t.integer :company_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :receive_cashes
  end
end
