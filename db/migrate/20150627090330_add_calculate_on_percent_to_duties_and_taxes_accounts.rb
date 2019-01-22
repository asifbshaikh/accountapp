class AddCalculateOnPercentToDutiesAndTaxesAccounts < ActiveRecord::Migration
  def change
    add_column :duties_and_taxes_accounts, :calculate_on_percent, :decimal, :precision=>5, :scale=>2, :default=>100.00
  end
end
