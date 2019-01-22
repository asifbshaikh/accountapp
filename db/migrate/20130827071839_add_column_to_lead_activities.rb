class AddColumnToLeadActivities < ActiveRecord::Migration
  def change
    add_column :lead_activities, :lead_activity, :boolean, :default=> false
  end
end
