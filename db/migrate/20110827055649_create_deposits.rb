class CreateDeposits < ActiveRecord::Migration
  def self.up
    create_table :deposits do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :voucher_number
      t.date :transaction_date
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
      t.string :description
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
    drop_table :deposits
  end
end
