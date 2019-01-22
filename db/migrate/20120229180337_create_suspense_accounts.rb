class CreateSuspenseAccounts < ActiveRecord::Migration
  def self.up
    create_table :suspense_accounts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :suspense_accounts
  end
end
