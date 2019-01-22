class CreateStockLedgers < ActiveRecord::Migration
  def change
    create_table :stock_ledgers do |t|
      t.integer :company_id, :null => false, :index => true
      t.integer :product_id, :null=> false, :index => true
      t.integer :voucher_id, :null => false
      t.string :voucher_type, :null => false
      t.integer :voucher_line_item_id
      t.integer :warehouse_id, :null => false, :index => true
      t.integer :branch_id, :index => true
      t.datetime :transaction_date, :null=> false, :index => true
      t.decimal :credit_quantity, :default => 0
      t.decimal :debit_quantity, :default => 0
      t.integer :created_by, :null =>  false
      t.decimal :unit_price, :scale=>2, :precision=>18, :default=>0

      t.timestamps
    end
  end
end
