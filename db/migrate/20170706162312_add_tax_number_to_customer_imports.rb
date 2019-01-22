class AddTaxNumberToCustomerImports < ActiveRecord::Migration
  def change
    add_column :customer_imports, :tax_number, :string, :limit=>32
  end
end
