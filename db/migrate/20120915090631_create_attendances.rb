class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.integer :company_id
      t.integer :user_id
      t.date :month
      t.decimal :days_present, :precision => 4, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :attendances
  end
end
