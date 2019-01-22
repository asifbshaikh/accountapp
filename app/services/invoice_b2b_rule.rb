class InvoiceB2BRule
		def classify(invoice) 
      if !invoice.export_invoice?
          if invoice.cash_invoice?
                gstn = invoice.cash_customer_gstin
              else
                #[FIXME] This logic should be moved to invoice model
                gstn = invoice.customer.present? ? invoice.customer.gstn_id : invoice.vendor.gstn_id 
              end  
              if gstn.present?
              	type = 'B2B'
              	type
              end
      end
          
		end
  
end
