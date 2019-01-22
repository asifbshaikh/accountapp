class CreateGstRequestLogs < ActiveRecord::Migration
  def change
    create_table :gst_request_logs do |t|
      t.integer :company_id
      t.integer :gsp_id
      t.string :action
      t.string :txn
      t.text :payload
      t.string :usr_ip_addr
      t.datetime :sent_time

      t.timestamps
    end
  end
end
