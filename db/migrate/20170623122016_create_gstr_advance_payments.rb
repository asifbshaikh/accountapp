class CreateGstrAdvancePayments < ActiveRecord::Migration
  def change
    create_table :gstr_advance_payments do |t|
      t.integer :company_id, :null => false
      t.string :voucher_number, :limit => 32, :null => true
      t.date :voucher_date, :null => true
      t.date :received_date, :null => true
      t.integer :from_account_id, :null => true
      t.integer :to_account_id, :null => true
      t.decimal :amount, :precision => 18,  :scale => 2, :null => true, :default => 0
      t.text :payment_details
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.datetime :deleted_datetime
      t.string :deleted_reason
      t.integer :restored_by
      t.datetime :restored_datetime
      t.integer :project_id
      t.integer :currency_id
      t.decimal :exchange_rate, :precision => 18, :scale => 5, :default => 0
      t.integer :status , :null => true
      t.integer :created_by, :null => false
      t.integer :purchase_id
      t.string :place_of_supply, :limit=>3, :null=> false
      t.timestamps
    end
  end
end
