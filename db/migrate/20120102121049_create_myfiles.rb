class CreateMyfiles < ActiveRecord::Migration
  def self.up
    create_table :myfiles do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :folder_id

      t.timestamps
    end
    add_index :myfiles, :user_id
    add_index :myfiles, :folder_id
  end

  def self.down
    drop_table :myfiles
  end
end
