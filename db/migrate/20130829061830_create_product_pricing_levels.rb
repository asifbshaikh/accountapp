class CreateProductPricingLevels < ActiveRecord::Migration
  def change
    create_table :product_pricing_levels do |t|
      t.integer :company_id
      t.string :caption
      t.decimal :discount_percent, :precision => 5, :scale => 2, :default => 0

      t.timestamps
    end
  end
end
