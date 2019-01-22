class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.integer :user_id, :null => false
      t.integer :parent_id
      t.string :name
      t.timestamps
    end
     add_index :folders, :parent_id  
     add_index :folders, :user_id
  end

  def self.down
    drop_table :folders
  end
end
