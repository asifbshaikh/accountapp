class OtherChargeLineItem < PurchaseLineItem
 validates_presence_of :account_id, :amount 
end