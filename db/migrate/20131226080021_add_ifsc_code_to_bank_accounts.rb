class AddIfscCodeToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :ifsc_code, :string
  end
end
