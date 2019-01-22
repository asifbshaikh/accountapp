class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|
      t.integer :company_id
      t.integer :plan_id
      t.integer :user_id
      t.string :subject
      t.text :message
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end

  def self.down
    drop_table :announcements
  end
end
