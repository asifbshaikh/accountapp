class CreateDutiesAndTaxesAccounts < ActiveRecord::Migration
  def self.up
    create_table :duties_and_taxes_accounts do |t|
      t.integer :tax_id
      t.decimal :tax_rate, :precision => 4, :scale => 2
      t.boolean :auto_calculate_tax
      t.timestamps
    end
  end

  def self.down
    drop_table :duties_and_taxes_accounts
  end
end
