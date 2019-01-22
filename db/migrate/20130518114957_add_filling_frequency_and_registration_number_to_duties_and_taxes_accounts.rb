class AddFillingFrequencyAndRegistrationNumberToDutiesAndTaxesAccounts < ActiveRecord::Migration
  def self.up
    add_column :duties_and_taxes_accounts, :filling_frequency, :integer
    add_column :duties_and_taxes_accounts, :registration_number, :string
  end

  def self.down
    remove_column :duties_and_taxes_accounts, :registration_number
    remove_column :duties_and_taxes_accounts, :filling_frequency
  end
end
