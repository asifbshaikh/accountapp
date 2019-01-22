class CreateCapitalAccounts < ActiveRecord::Migration
  def self.up
    create_table :capital_accounts do |t|
      t.string :name
      t.text :address
      t.string :city
      t.string :state
      t.string :PIN
      t.string :PAN
      t.string :sales_tax_no
      t.string :service_tax_no
    end
  end

  def self.down
    drop_table :capital_accounts
  end
end
