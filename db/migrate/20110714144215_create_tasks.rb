class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :created_by, :null => false
      t.integer :assigned_to, :null => false
      t.string :description
      t.date :due_date
      t.integer :priority
      t.integer :task_status
      
      

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
