class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :account_id, :null => false
      t.integer :cutoff_level1
      t.integer :cutoff_level2
      t.integer :quantity, :precision => 10, :scale => 2
      t.string :unit_of_measure

      t.timestamps
    end
  end

  def self.down
    drop_table :inventories
  end
end
