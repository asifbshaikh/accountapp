class CreateProductImports < ActiveRecord::Migration
  def change
    create_table :product_imports do |t|
      t.integer :import_file_id
      t.string :name
      t.string :description
      t.string :warehouse
      t.decimal :quantity, :precision => 10, :scale => 2
      t.integer :batch_no
      t.decimal :unit_price, :precision => 10, :scale => 2
      t.decimal :reorder_level, :precision => 10, :scale => 2
      t.string :unit_of_measure
      t.decimal :sales_price, :precision => 18, :scale => 2
      t.string :income_account
      t.decimal :purchase_price, :precision => 18, :scale => 2
      t.string :expense_account
      t.integer :status

      t.timestamps
    end
  end
end
