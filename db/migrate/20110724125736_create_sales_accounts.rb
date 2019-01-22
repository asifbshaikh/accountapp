class CreateSalesAccounts < ActiveRecord::Migration
  def self.up
    create_table :sales_accounts do |t|
      t.boolean :inventoriable

      t.timestamps
    end
  end

  def self.down
    drop_table :sales_accounts
  end
end
