class ChangeDataTypeToTimesheets < ActiveRecord::Migration
  def self.up
    change_table :timesheets do |t|
      t.change :start_date, :date
      t.change :end_date, :date
      t.change :record_date, :date
    end
  end

  def self.down
    change_table :timesheets do |t|
      t.change :start_date, :integer
      t.change :end_date, :integer
      t.change :record_date, :integer
    end
  end
end
