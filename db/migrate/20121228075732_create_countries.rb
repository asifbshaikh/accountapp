class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name, :limit => 80
      t.string :isd_code, :limit => 5
      t.string :currency_unicode, :limit => 10
      t.string :currency_code, :limit => 3

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
