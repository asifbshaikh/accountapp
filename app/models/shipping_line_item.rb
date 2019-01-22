class ShippingLineItem < InvoiceLineItem
 validates_presence_of :account_id, :amount 
end