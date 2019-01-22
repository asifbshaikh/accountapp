class CreateLeaveRequests < ActiveRecord::Migration
  def self.up
    create_table :leave_requests do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :approved_by
      t.integer :leave_type_id, :null => false
      t.integer :leave_status
      t.date :start_date, :mull => false
      t.date :end_date, :null => false
      t.text :reason_for_leave
      t.string :contact_during_leave, :limit => 10
      

      t.timestamps
    end
  end

  def self.down
    drop_table :leave_requests
  end
end
