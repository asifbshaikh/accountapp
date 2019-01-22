class CreatePurchaseAccounts < ActiveRecord::Migration
  def self.up
    create_table :purchase_accounts do |t|
      t.boolean :inventoriable

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_accounts
  end
end
