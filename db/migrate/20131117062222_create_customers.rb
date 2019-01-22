class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :company_id, :null => false;
      t.string :name, :null => false
      t.string :phone_number
      t.string :fax
      t.string :email
      t.string :website
      t.string :pan, :limit => 25
      t.string :tan, :limit => 25
      t.string :vat_tin, :limit => 25
      t.string :cst_reg_no, :limit => 25
      t.string :cin, :limit => 25
      t.string :excise_reg_no, :limit => 25
      t.string :service_tax_reg_no, :limit => 25
      t.integer :product_pricing_level_id
      t.string :country, :limit => 100
      t.string :weekly_off, :limit => 50
      t.string :open_time, :limit => 10
      t.string :close_time, :limit => 10
      t.string :bank_name
      t.string :ifsc_code, :limit => 25
      t.string :micr_code, :limit => 25
      t.string :bsr_code, :limit => 25
      t.date :incorporated_date
      t.integer :credit_days
      t.decimal :credit_limit
      t.integer :created_by, :null => false
      t.text :background_info
      t.text :notes

      t.timestamps
    end
  end
end
