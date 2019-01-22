class CreateTimesheets < ActiveRecord::Migration
  def self.up
    create_table :timesheets do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :start_date
      t.integer :end_date
      t.integer :record_date

      t.timestamps
    end
  end

  def self.down
    drop_table :timesheets
  end
end
