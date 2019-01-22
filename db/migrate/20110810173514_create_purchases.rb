class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :purchase_number
      t.integer :account_id, :null => false
      t.date :bill_date
      t.date :record_date
      t.date :due_date
      t.string :bill_reference
      t.boolean :deleted
      t.text :customer_notes
      t.text :terms_and_conditions
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
    drop_table :purchases
  end
end
