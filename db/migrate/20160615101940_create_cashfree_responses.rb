class CreateCashfreeResponses < ActiveRecord::Migration
  def change
    create_table :cashfree_responses do |t|

    	t.string :order_id, :null => false
    	t.decimal :order_amount, :precision => 18, :scale => 2, :default => 0.0
    	t.string :reference_id, :null => false
    	t.string  :tx_status, :null => true
    	t.string  :payment_mode, :null => true
    	t.string  :tx_message, :null => false
    	t.string  :tx_time, :null => false
    	t.string  :signature, :null=> false

      t.timestamps
    end
  end
end
