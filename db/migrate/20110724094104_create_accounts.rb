class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :company_id, :null => false
      t.integer :account_head_id, :null => false
      t.string	:name, :limit => 255, :null => false
      t.integer :accountable_id
      t.string  :accountable_type
      t.decimal :opening_balance, :precision => 18, :scale => 2, :default =>0
      t.integer :created_by, :null => false
      t.integer :approved_by	
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
    drop_table :accounts
  end
end
