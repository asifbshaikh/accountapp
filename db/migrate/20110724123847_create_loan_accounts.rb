class CreateLoanAccounts < ActiveRecord::Migration
  def self.up
    create_table :loan_accounts do |t|
      t.string :account_number, :limit => 50, :null => false
      t.string :bank_name, :null => false
      t.string :loan_type
      t.decimal :interest_rate, :precision => 4, :scale =>2, :default => 0
      t.string :details

      t.timestamps
    end
  end

  def self.down
    drop_table :loan_accounts
  end
end
