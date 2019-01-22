class CreateCashfreePaymentLinks < ActiveRecord::Migration
  def change
    create_table :cashfree_payment_links do |t|
      t.integer :company_id, :null => false
      t.integer  :invoice_id, :null => false
      t.string   :order_id, :null => false
      t.string   :order_amount, :null => false
      t.string   :order_note, :null => true
      t.string   :customer_name, :null => true
      t.integer  :customer_phone, :null => false
      t.string   :customer_email, :null => true
      t.integer  :seller_phone, :null => true
      t.string   :shorturl, :null => true
      t.string   :created_by, :null => false
      t.string   :status, :null => false

      t.timestamps
    end
  end
end
