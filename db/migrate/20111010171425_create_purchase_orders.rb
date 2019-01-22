class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :purchase_order_number
      t.integer :account_id, :null => false
      t.date :po_date
      t.date :record_date, :null => false
      t.string :bill_reference
      t.integer :status
      t.boolean :deleted
      t.integer :deleted_by
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
    drop_table :purchase_orders
  end
end
