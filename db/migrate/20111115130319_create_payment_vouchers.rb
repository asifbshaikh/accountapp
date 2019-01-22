class CreatePaymentVouchers < ActiveRecord::Migration
  def self.up
    create_table :payment_vouchers do |t|
      t.integer :company_id, :null => false
      t.integer :purchase_id
      t.integer :created_by, :null => false
      t.string :voucher_number,  :limit => 32, :null => false
      t.date :voucher_date, :null => false
      t.date :payment_date, :null => false
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0, :null => false
      t.text :description
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.datetime :deleted_datetime
      t.string :deleted_reason
      t.integer :restored_by
      t.datetime :restored_datetime
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :payment_vouchers
  end
end
