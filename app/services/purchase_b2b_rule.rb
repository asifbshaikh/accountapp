class PurchaseB2BRule
  
  def classify(purchase) 

    gstn = purchase.customer_GSTIN
    
    if gstn.present?

      if  purchase.nil_rated_account(purchase)
        type = 'NIL'
       
      else
        type = 'B2B'
      end

    else
      
      if  purchase.nil_rated_account(purchase)
        type = 'NIL'
      
      else
        type = 'B2BUR'
      end

      type
    end   
  end
end