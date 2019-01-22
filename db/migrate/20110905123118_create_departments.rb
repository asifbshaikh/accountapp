class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.integer :company_id
      t.integer :user_id
      t.string :name
      t.text :description, :limit => 500
      t.string :status
      
      t.timestamps
    end
  end

  def self.down
    drop_table :departments
  end
end
