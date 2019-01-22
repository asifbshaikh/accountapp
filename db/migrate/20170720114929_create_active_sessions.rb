class CreateActiveSessions < ActiveRecord::Migration
  def change
    create_table :active_sessions do |t|
      t.integer :company_id, :null => false
    	t.integer :gsp_id, :null=>false
    	t.string :auth_token
    	t.integer :expiry
      t.datetime :start_time
      t.datetime :end_time
    	t.string :sek
    	t.string :remote_user_ip
    	t.integer :status
      t.timestamps
    end
  end
end
