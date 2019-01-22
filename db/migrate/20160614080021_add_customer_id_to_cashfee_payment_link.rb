class AddCustomerIdToCashfeePaymentLink < ActiveRecord::Migration
  def change
     	add_column :cashfree_payment_links,:customer_id,:integer
   end
end
