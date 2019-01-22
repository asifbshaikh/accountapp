class CreateProductBatches < ActiveRecord::Migration
  def change
    create_table :product_batches do |t|
      t.integer :product_id
      t.integer :warehouse_id
      t.string :batch_number
      t.decimal :quantity, :default => 0.0, :precision => 10, :scale => 2
      t.date :manufacture_date
      t.date :expiry_date

      t.timestamps
    end
  end
end
