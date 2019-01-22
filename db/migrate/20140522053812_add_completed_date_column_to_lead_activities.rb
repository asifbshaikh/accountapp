class AddCompletedDateColumnToLeadActivities < ActiveRecord::Migration
  def change
    add_column :lead_activities, :completed_date, :date
  end
end
