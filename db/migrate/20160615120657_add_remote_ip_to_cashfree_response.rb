class AddRemoteIpToCashfreeResponse < ActiveRecord::Migration
  def change
  	add_column :cashfree_responses,:remote_ip, :string, :limit => 100	
  end
end
