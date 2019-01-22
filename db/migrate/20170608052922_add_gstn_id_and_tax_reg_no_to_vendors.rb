class AddGstnIdAndTaxRegNoToVendors < ActiveRecord::Migration
  def change
  	add_column :vendors, :gstn_id, :string
  	add_column :vendors, :tax_reg_no, :string
  end
end
