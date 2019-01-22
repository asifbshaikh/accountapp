class AddCompletedDateToTasks < ActiveRecord::Migration
  def change
	add_column :tasks, :completed_date, :date
  end
end
