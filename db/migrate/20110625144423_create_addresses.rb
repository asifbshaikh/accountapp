class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string  :address_line1, :limit => 100
      t.string  :address_line2, :limit => 100
      t.string  :city, :limit => 100
      t.string  :state, :limit => 100
      t.string  :country, :limit => 100
      t.string  :postal_code, :limit => 7
      t.integer :addressable_id
      t.string  :addressable_type
    end
  end

  def self.down
    drop_table :addresses
  end
end
