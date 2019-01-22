class CreateInvestmentAccounts < ActiveRecord::Migration
  def self.up
    create_table :investment_accounts do |t|
      t.boolean :inventoriable
    end
  end

  def self.down
    drop_table :investment_accounts
  end
end
