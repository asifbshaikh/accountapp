class AddTaxColumnsToSundryCreditors < ActiveRecord::Migration
  def self.up
    add_column :sundry_creditors, :tan, :string, :limit => 25
    add_column :sundry_creditors, :vat_tin, :string, :limit => 25
    add_column :sundry_creditors, :cst, :string, :limit => 25
    add_column :sundry_creditors, :excise_reg_no, :string, :limit => 25
    add_column :sundry_creditors, :service_tax_reg_no, :string, :limit => 25
  end

  def self.down
    remove_column :sundry_creditors, :service_tax_reg_no
    remove_column :sundry_creditors, :excise_reg_no
    remove_column :sundry_creditors, :cst
    remove_column :sundry_creditors, :vat_tin
    remove_column :sundry_creditors, :tan
  end
end
