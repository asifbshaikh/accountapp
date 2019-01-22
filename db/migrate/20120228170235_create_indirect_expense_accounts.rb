class CreateIndirectExpenseAccounts < ActiveRecord::Migration
  def self.up
    create_table :indirect_expense_accounts do |t|
      t.boolean :inventoriable
    end
  end

  def self.down
    drop_table :indirect_expense_accounts
  end
end
