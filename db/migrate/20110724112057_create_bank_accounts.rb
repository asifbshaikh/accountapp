class CreateBankAccounts < ActiveRecord::Migration
  def self.up
    create_table :bank_accounts do |t|
      t.string :account_number, :null => false, :limit => 50
      t.string :bank_name, :null => false
      t.string :rtgs_code, :limit => 25
      t.string :micr_code, :limit => 25

      t.timestamps
    end
  end

  def self.down
    drop_table :bank_accounts
  end
end
