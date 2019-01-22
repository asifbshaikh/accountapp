class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :company_id, :null => false
      t.string  :username, :null => false, :limit => 32
      t.string  :hashed_password, :null => false
      t.string  :salt, :null => false
      t.string  :first_name, :null => false, :limit =>100
      t.string  :last_name, :null => false, :limit =>100
      t.string  :email, :null => false
      t.integer :department_id
      t.integer :designation_id
      t.integer :reporting_to_id
      t.datetime :last_login
      t.boolean :deleted, :default => false
      t.datetime :deleted_datetime
      t.integer :deleted_by
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
