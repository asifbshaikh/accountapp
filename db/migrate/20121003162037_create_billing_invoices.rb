class CreateBillingInvoices < ActiveRecord::Migration
  def self.up
    create_table :billing_invoices do |t|
      t.integer :company_id
      t.string :invoice_number, :null => false
      t.datetime :invoice_date, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0 
      t.integer :created_by, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_invoices
  end
end
