class CreateIncomeVouchers < ActiveRecord::Migration
  def self.up
    create_table :income_vouchers do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :voucher_number, :limit => 32, :null => false
      t.date :income_date, :null => false
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.decimal :amount,:precision => 18,  :scale => 2, :null => false, :default => 0
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
    drop_table :income_vouchers
  end
end
