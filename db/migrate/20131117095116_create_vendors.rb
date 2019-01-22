class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.integer :company_id, :null => false
      t.string :name, :null => false
      t.string :email
      t.string :pan
      t.string :sales_tax_no
      t.string :tan
      t.string :vat_tin
      t.string :cst
      t.string :excise_reg_no
      t.string :service_tax_reg_no
      t.string :website
      t.string :incorporated_date

      t.timestamps
    end
  end
end
