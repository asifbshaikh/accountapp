class CreateUserSalaryDetails < ActiveRecord::Migration
  def self.up
    create_table :user_salary_details do |t|
      t.integer :user_id, :null => false
      t.string :work_type
      t.integer :status
      t.text :work_location
      t.string :work_phone, :limit => 10
      t.date :date_of_joining
      t.string :bank_account_number, :limit => 20
      t.string :branch
      t.string :bank_name
      t.string :PAN
      t.string :EPS_account_number, :limit => 25
      t.string :PF_account_number, :limit => 25

      t.timestamps
    end
  end

  def self.down
    drop_table :user_salary_details
  end
end
