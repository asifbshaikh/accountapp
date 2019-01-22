class PurchaseB2BURRule
    def classify(purchase) 
      gstn = purchase.vendor.present? ? purchase.vendor.gstn_id : purchase.customer.gstn_id 
               
              if gstn.blank?
                type = 'B2BBUR'
                type
              end
      end
          
  
  
end