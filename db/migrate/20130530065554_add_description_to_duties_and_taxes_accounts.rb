class AddDescriptionToDutiesAndTaxesAccounts < ActiveRecord::Migration
  def self.up
    add_column :duties_and_taxes_accounts, :description, :text
  end

  def self.down
    remove_column :duties_and_taxes_accounts, :description
  end
end
