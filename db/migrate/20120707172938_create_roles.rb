class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.integer :plan_id	
      t.string :name, :limit => 100, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
