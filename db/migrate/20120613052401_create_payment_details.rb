class CreatePaymentDetails < ActiveRecord::Migration
  def self.up
    create_table :payment_details do |t|
      t.integer :voucher_id,  :null => false
      t.string :voucher_type, :null => false
      t.decimal :amount,      :precision => 18, :scale => 2, :default => 0
      t.date :payment_date,   :null => false
      t.string :account_number, :limit => 16
      t.string :bank_name
      t.string :transaction_reference, :limit => 50
      t.string :branch
      t.string :type,         :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_details
  end
end
