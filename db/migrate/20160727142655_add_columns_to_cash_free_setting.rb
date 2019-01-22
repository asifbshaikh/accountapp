class AddColumnsToCashFreeSetting < ActiveRecord::Migration
  def change
  	add_column :cash_free_settings, :expense_account, :integer
  	add_column :cash_free_settings, :expense_tax_account, :integer
  	
  end
end
