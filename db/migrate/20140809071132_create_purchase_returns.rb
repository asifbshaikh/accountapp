class CreatePurchaseReturns < ActiveRecord::Migration
  def change
    create_table :purchase_returns do |t|
      t.integer :company_id, :null=>false
      t.integer :purchase_id, :null=>false
      t.integer :created_by, :null=>false
      t.string :purchase_return_number
      t.integer :account_id, :null=>false
      t.date :record_date
      t.text :customer_notes
      t.decimal :total_amount, :decimal, :precision => 18, :scale => 2, :default => 0.0
      t.integer :currency_id
      t.decimal :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0.0

      t.timestamps
    end
  end
end
