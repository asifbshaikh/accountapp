class AddImportPurchasesToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :import_purchase, :boolean, :default => false
    add_column :purchases, :boe_date, :date
    add_column :purchases, :boe_num, :string
    add_column :purchases, :boe_value, :decimal
  end
end
