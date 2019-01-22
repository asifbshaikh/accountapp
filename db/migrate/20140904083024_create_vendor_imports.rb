class CreateVendorImports < ActiveRecord::Migration
  def change
    create_table :vendor_imports do |t|
      t.integer :import_file_id
      t.string :name
      t.string :opening_balance
      t.string :phone_number
      t.string :currency
      t.string :email
      t.string :website
      t.string :pan
      t.string :tan
      t.string :vat_tin
      t.string :excise_reg_no
      t.string :service_tax_reg_no
      t.string :sales_tax_no
      t.string :lbt_registration_number
      t.string :cst
      t.string :billing_address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :shipping_address
      t.integer :created_by
      t.integer :status

      t.timestamps
    end
  end
end
