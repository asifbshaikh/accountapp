class CreateUsernotes < ActiveRecord::Migration
  def self.up
    create_table :usernotes do |t|
      t.integer :user_id, :null => false
      t.string :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :usernotes
  end
end
