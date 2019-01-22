class CreateStockHistories < ActiveRecord::Migration
  def change
    create_table :stock_histories do |t|
      t.integer :company_id
      t.integer :stock_id
      t.integer :financial_year_id
      t.decimal :opening_stock, :precision=>18, :scale=>2, :default=>0
      t.decimal :opening_stock_value, :precision=>18, :scale=>2, :default=>0

      t.timestamps
    end
  end
end
