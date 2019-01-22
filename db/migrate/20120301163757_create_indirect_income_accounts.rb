class CreateIndirectIncomeAccounts < ActiveRecord::Migration
  def self.up
    create_table :indirect_income_accounts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :indirect_income_accounts
  end
end
