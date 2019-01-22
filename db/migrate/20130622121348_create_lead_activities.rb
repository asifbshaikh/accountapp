class CreateLeadActivities < ActiveRecord::Migration
  def self.up
    create_table :lead_activities do |t|
      t.integer :lead_id
      t.integer :activity
      t.datetime :record_date
      t.decimal :time_spent
      t.text :outcome
      t.datetime :next_followup

      t.timestamps
    end
  end

  def self.down
    drop_table :lead_activities
  end
end
