class AddProjectIdToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :project_id, :integer
  end
end
