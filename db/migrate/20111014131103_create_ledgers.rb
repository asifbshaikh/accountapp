class CreateLedgers < ActiveRecord::Migration
  def self.up
    create_table :ledgers do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :created_by, :null => false
      t.date :transaction_date, :null => false
      t.decimal :debit , :precision => 18, :scale => 2, :default => 0
      t.decimal :credit, :precision => 18, :scale => 2, :default => 0
      t.string :voucher_number, :null => false
      t.references :voucher, :polymorphic => true
      t.date :bank_transaction_date, :null => true
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
    drop_table :ledgers
  end
end
