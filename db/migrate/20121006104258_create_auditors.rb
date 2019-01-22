class CreateAuditors < ActiveRecord::Migration
  def self.up
    create_table :auditors do |t|
      t.string :first_name, :null => false, :limit => 100
      t.string :last_name, :null => false, :limit => 100
      t.string :username, :null => false, :limit => 32
      t.string :hashed_password, :null => false, :limit => 255
      t.string :salt, :null => false, :limit => 255
      t.boolean :reset_password

      t.timestamps
    end
  end

  def self.down
    drop_table :auditors
  end
end
