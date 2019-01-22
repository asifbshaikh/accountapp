class CreateEmployeeGoals < ActiveRecord::Migration
  def self.up
    create_table :employee_goals do |t|
      t.integer :company_id, :null => false
      t.integer :for_employee, :null => false
      t.integer :created_by, :null => false
      t.integer :goals
      t.date :from_date, :null => false
      t.date :to_date, :null => false
      t.text :employee_comments, :limit => 1000
      t.text :manager_comments, :limit => 1000
      

      t.timestamps
    end
  end

  def self.down
    drop_table :employee_goals
  end
end
