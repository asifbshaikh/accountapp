class RemoveStartDateAndEndDateFromYears < ActiveRecord::Migration
  def self.up
  	remove_column :years, :start_date
  	remove_column :years, :end_date
  end

  def self.down
  	add_column :years, :start_date
  	add_column :years, :end_date
  end
end
