class AddProductPricingLevelIdToSundryDebtors < ActiveRecord::Migration
  def change
    add_column :sundry_debtors, :product_pricing_level_id, :integer
  end
end
