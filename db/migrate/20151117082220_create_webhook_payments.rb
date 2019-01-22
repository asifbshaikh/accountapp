class CreateWebhookPayments < ActiveRecord::Migration
  def change
    create_table :webhook_payments do |t|
    	t.string :payment_request_id, :null => false
    	t.string :payment_id, :null => false
    	t.string  :customer_name, :null => true
    	t.string  :currency, :null => false
    	t.decimal :amount, :precision => 18, :scale => 2, :default => 0.0
    	t.decimal :fees, :decimal, :precision => 18, :scale => 2, :default => 0.0
    	t.string  :longurl, :null => false
    	t.string  :mac, :null=> false
    	t.string  :status, :null => false

      t.timestamps
    end
  end
end
