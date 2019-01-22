class CreateCustomerImports < ActiveRecord::Migration
  def change
    create_table :customer_imports do |t|
      t.integer :import_file_id
      t.string :name
      t.string :opening_balance
      t.string :currency
      t.string :phone_number
      t.string :email
      t.string :website
      t.string :pan
      t.string :tan
      t.string :vat_tin
      t.string :cst_reg_no
      t.string :cin
      t.string :excise_reg_no
      t.string :service_tax_reg_no
      t.string :lbt_registration_number
      t.string :credit_days
      t.string :credit_limit
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
