class AddDaysAbsentToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :days_absent, :decimal, :precision => 4, :scale => 2, :default => 0.0
  end
end
