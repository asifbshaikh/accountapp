class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :created_by, :null => false
      t.string  :name, :null => false, :size => 100
      t.string  :unit_of_measure, :size => 100

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
