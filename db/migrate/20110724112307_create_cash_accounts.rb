class CreateCashAccounts < ActiveRecord::Migration
  def self.up
    create_table :cash_accounts do |t|
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :cash_accounts
  end
end
