class AddTaxColumnsToSundryDebtors < ActiveRecord::Migration
  def self.up
    add_column :sundry_debtors, :tan, :string, :limit => 25
    add_column :sundry_debtors, :vat_tin, :string, :limit => 25
    add_column :sundry_debtors, :cst, :string, :limit => 25
    add_column :sundry_debtors, :excise_reg_no, :string, :limit => 25
    add_column :sundry_debtors, :service_tax_reg_no, :string, :limit => 25
  end

  def self.down
    remove_column :sundry_debtors, :service_tax_reg_no
    remove_column :sundry_debtors, :excise_reg_no
    remove_column :sundry_debtors, :cst
    remove_column :sundry_debtors, :vat_tin
    remove_column :sundry_debtors, :tan
  end
end
