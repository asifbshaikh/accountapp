class AddEmailToCapitalAccount < ActiveRecord::Migration
  def self.up
    add_column :capital_accounts, :email, :string
  end

  def self.down
    remove_column :capital_accounts, :email
  end
end
