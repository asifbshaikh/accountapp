class CreatePaymentGateways < ActiveRecord::Migration
  def self.up
    create_table :payment_gateways do |t|
      t.string :name, :null => false
      t.string :key, :null => false
      t.string :api_key
      t.string :vanity_url, :null => false
      t.string :gateway_url, :null => false
      t.boolean :production, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_gateways
  end
end
