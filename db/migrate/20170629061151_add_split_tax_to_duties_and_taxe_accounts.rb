class AddSplitTaxToDutiesAndTaxeAccounts < ActiveRecord::Migration
  def change
  	add_column :duties_and_taxes_accounts, :split_tax,:integer
  end
end
