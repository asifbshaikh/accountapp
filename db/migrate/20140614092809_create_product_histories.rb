class CreateProductHistories < ActiveRecord::Migration
  def change
    create_table :product_histories do |t|
      t.integer :company_id
      t.integer :product_id
      t.integer :financial_year_id
      t.decimal :opening_stock, :precision=>18, :scale=>2, :default=>0
      t.decimal :unit_value, :precision=>18, :scale=>2, :default=>0
      t.timestamps
    end
  end
end
