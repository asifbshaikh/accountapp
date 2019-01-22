class InvoiceB2CLRule
  #[FIXME] why is this condition coming again and again? 
  # Can we making this is the first rule that gets executed?
def classify(invoice) 
	if !invoice.export_invoice?
	 if invoice.cash_invoice? 
                gstn = invoice.cash_customer_gstin
      else 
                gstn = invoice.customer.present? ? invoice.customer.gstn_id : invoice.vendor.gstn_id 
      end  
      if gstn.blank? && invoice.total_amount > 250000  && (invoice.place_of_supply != invoice.company.gstn_state_code)
              	type = 'B2CL'
              	type
       end
     end
end
end
