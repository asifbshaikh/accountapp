class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :currency_code, :limit => 3, :null => false
      t.string :symbol, :limit => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :currencies
  end
end
