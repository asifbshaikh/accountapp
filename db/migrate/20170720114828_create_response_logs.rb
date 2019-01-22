class CreateResponseLogs < ActiveRecord::Migration
  def change
    create_table :response_logs do |t|
     t.integer :txn_id, :null=>false
     t.integer :request_log_id, :null=>false
     t.text :response_payload
     t.string :remote_user_ip
     t.datetime :timestamp_field
     t.timestamps
    end
  end
end
