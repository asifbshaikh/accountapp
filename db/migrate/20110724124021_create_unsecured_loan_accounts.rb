class CreateUnsecuredLoanAccounts < ActiveRecord::Migration
  def self.up
    create_table :unsecured_loan_accounts do |t|
      t.string :entity_name, :null => false
      t.string :loan_type
      t.decimal :interest_rate, :precision => 4, :scale => 2, :default => 0
      t.string :details

      t.timestamps
    end
  end

  def self.down
    drop_table :unsecured_loan_accounts
  end
end
