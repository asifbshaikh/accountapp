class CreateTimesheetLineItems < ActiveRecord::Migration
  def self.up
    create_table :timesheet_line_items do |t|
      t.integer :timesheet_id, :null => false
      t.integer :task_id, :null => false
      t.decimal :timestamp
      t.date :day
      t.integer :holiday_id
      t.integer :leave_id
      t.timestamps
    end
  end

  def self.down
    drop_table :timesheet_line_items
  end
end
