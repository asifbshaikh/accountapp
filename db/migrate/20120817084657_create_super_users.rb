class CreateSuperUsers < ActiveRecord::Migration
  def self.up
    create_table :super_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :email
      t.string :hashed_password
      t.string :salt
      t.string :role
      t.boolean :active
      t.datetime :last_login

      t.timestamps
    end
  end

  def self.down
    drop_table :super_users
  end
end
