class CreateProductSettings < ActiveRecord::Migration
  def change
    create_table :product_settings do |t|
      t.integer :company_id
      t.boolean :multilevel_pricing, :default => false

      t.timestamps
    end
  end
end
