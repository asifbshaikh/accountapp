class CreateDirectIncomeAccounts < ActiveRecord::Migration
  def self.up
    create_table :direct_income_accounts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :direct_income_accounts
  end
end
