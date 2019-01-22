class CreateInvoiceReturns < ActiveRecord::Migration
  def change
    create_table :invoice_returns do |t|
      t.integer :company_id, :null=>false
      t.integer :invoice_id, :null=>false
      t.integer :created_by, :null=>false
      t.string :invoice_return_number
      t.integer :account_id, :null=>false
      t.date :record_date
      t.text :description
      t.decimal :total_amount, :precision=> 18, :scale=>2, :default=>0.0
      t.integer :currency_id
      t.decimal :exchange_rate, :precision=>18, :scale=>5, :default=>0.0
      t.integer :credit_note_id
      t.integer :warehouse_id

      t.timestamps
    end
  end
end
