class CreateDirectExpenseAccounts < ActiveRecord::Migration
  def self.up
    create_table :direct_expense_accounts do |t|
      t.boolean :inventoriable
    end
  end

  def self.down
    drop_table :direct_expense_accounts
  end
end
