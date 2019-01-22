class CreateRequestLogs < ActiveRecord::Migration
  def change
    create_table :request_logs do |t|
      t.integer :company_id, :null => false
      t.string :txn_id, :null=>false
      t.integer :gsp_id, :null=>false
      t.string :action, :null=>false
      t.text :payload
      t.string :remote_user_ip
      t.datetime :send_time
      t.timestamps
    end
  end
end
