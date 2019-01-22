class CreateInstamojoPaymentLinks < ActiveRecord::Migration
  def change
    create_table :instamojo_payment_links do |t|

      t.integer :company_id, :null => false
      t.integer :invoice_id, :null => false
      t.integer :payment_request_id, :null => false

      t.string   :customer_name, :null => true
      t.string   :purpose, :null=> false
      t.string   :amount, :null => false
      t.string   :longurl, :null => false
      t.string   :shorturl, :null => true
      t.string   :created_by, :null => false
      t.string   :status, :null => false

      t.timestamps
    end
  end
end
