class AddTaxFieldsToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :phone, :string, :limit => 100
    add_column :companies, :fax, :string, :limit => 100
    add_column :companies, :email, :string
    add_column :companies, :VAT_no, :string
    add_column :companies, :CST_no, :string
    add_column :companies, :excise_reg_no, :string
    add_column :companies, :service_tax_reg_no, :string
  end

  def self.down
    remove_column :companies, :service_tax_reg_no
    remove_column :companies, :excise_reg_no
    remove_column :companies, :CST_no
    remove_column :companies, :VAT_no
    remove_column :companies, :email
    remove_column :companies, :fax
    remove_column :companies, :phone
  end
end
