class AddRemoteIpToUsers < ActiveRecord::Migration

  def change
    add_column :users, :remote_ip, :string, :limit => 15
  end
end
