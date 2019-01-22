class CreateCompanyCurrencies < ActiveRecord::Migration
  def self.up
    create_table :company_currencies do |t|
      t.integer :company_id
      t.integer :currency_id

      t.timestamps
    end
  end

  def self.down
    drop_table :company_currencies
  end
end
