class AddCorrespondingAccountToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :corresponding_account_id, :integer, :nil => false
  end
end
