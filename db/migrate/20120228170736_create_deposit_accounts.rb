class CreateDepositAccounts < ActiveRecord::Migration
  def self.up
    create_table :deposit_accounts do |t|
      t.boolean :interest_applicable
      t.decimal :interest_rate, :precision => 4, :scale => 2
      t.integer :compounding_type
    end
  end

  def self.down
    drop_table :deposit_accounts
  end
end
