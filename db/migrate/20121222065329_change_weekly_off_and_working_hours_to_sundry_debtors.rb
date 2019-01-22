class ChangeWeeklyOffAndWorkingHoursToSundryDebtors < ActiveRecord::Migration
  def self.up
  	change_column :sundry_debtors, :weekly_off, :string, :limit => 50
  	change_table :sundry_debtors do |t|
  		t.change :open_time, :string, :limit => 10
  		t.change :close_time, :string, :limit => 10
  	end
  end

  def self.down
  	change_column :sundry_debtors, :weekly_off, :string, :limit => 10
  	change_table :sundry_debtors do |t|
  		t.change :open_time, :integer
  		t.change :close_time, :integer
  	end
  end
end
