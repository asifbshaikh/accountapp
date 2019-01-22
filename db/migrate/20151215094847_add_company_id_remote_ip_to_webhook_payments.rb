class AddCompanyIdRemoteIpToWebhookPayments < ActiveRecord::Migration
  def change
  	add_column :webhook_payments,:remote_ip, :string, :limit => 100	
  	add_column :instamojo_payment_links,:customer_id, :integer, :null => false
  end
end
