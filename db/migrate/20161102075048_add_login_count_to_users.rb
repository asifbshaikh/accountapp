class AddLoginCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_count, :integer
  end
end
