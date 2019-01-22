class InvoiceSalesOrder < ActiveRecord::Base
 belongs_to :invoice
 belongs_to :sales_order
 after_destroy :update_sales_order_status

 def update_sales_order_status
 	sales_order.update_billing_status
 end
end
