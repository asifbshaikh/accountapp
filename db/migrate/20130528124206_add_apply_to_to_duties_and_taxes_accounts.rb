class AddApplyToToDutiesAndTaxesAccounts < ActiveRecord::Migration
  def self.up
    add_column :duties_and_taxes_accounts, :apply_to, :integer
  end

  def self.down
    remove_column :duties_and_taxes_accounts, :apply_to
  end
end
