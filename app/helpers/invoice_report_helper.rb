module InvoiceReportHelper

	def customer_name(account)
    	@account.blank? ? "All customers" : @account.name
  	end
end
