class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :created_by, :null => false
      t.string :invoice_number
      t.date :invoice_date, :null => false
      t.date :due_date, :null => false
      t.string :po_reference
      t.text :customer_notes
      t.text :terms_and_conditions
      t.integer :invoice_status_id
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
    drop_table :invoices
  end
end
