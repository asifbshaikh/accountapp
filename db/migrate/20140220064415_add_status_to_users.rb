class AddStatusToUsers < ActiveRecord::Migration
  def change
	add_column :users, :restored_by, :integer
	add_column :users, :restored_datetime, :datetime
  end
end
