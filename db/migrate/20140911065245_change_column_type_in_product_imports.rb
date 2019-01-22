class ChangeColumnTypeInProductImports < ActiveRecord::Migration
  def up
    change_column :product_imports, :quantity, :string
    change_column :product_imports, :batch_no, :string
    change_column :product_imports, :unit_price, :string
    change_column :product_imports, :reorder_level, :string
    change_column :product_imports, :sales_price, :string
    change_column :product_imports, :purchase_price, :string
  end
end
