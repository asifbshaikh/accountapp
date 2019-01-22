class AddCalculationMethodToDutiesAndTaxesAccounts < ActiveRecord::Migration
  def change
    add_column :duties_and_taxes_accounts, :calculation_method, :integer, :default=>0
  end
end
