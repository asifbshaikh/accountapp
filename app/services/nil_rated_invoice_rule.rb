class NilRatedRule
		def classify(invoice) 
              if self.nil_rated_account(invoice)
              	type = 'NIL'
              	type
              end
          
		end

		#[FIXME] This logic should be moved to invoice model. See the changes I made for GSTR3B report	
		def  nil_rated_account invoice
				nil_account= false
				  invoice.tax_line_items.each do |line_item|
				     nil_account = true if line_item.account.name.include?("@Nil")
				  end
				  nil_account
		end
  
end
