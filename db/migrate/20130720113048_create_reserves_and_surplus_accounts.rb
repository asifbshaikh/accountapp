class CreateReservesAndSurplusAccounts < ActiveRecord::Migration
  def self.up
    create_table :reserves_and_surplus_accounts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :reserves_and_surplus_accounts
  end
end
