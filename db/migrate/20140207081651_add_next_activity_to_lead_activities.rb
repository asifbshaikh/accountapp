class AddNextActivityToLeadActivities < ActiveRecord::Migration
  def change
	add_column :lead_activities, :next_activity, :integer
  end
end
