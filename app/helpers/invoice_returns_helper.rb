module InvoiceReturnsHelper
	def invoice_return_line_applied_taxes(invoice_return_line_item)
		names=""
		invoice_return_line_item.invoice_return_taxes.each do |tax|
			unless tax.account.blank? 
				names+= ", " if invoice_return_line_item.invoice_return_taxes.last.equal?(tax) && !invoice_return_line_item.invoice_return_taxes.first.equal?(tax)
				names+= tax.account.name.chomp('on sales')
			end
		end
		names
	end
	def invoice_return_sub_total
		"#{number_with_precision @invoice_return.invoice_return_line_items.sum(:amount),:precision=>2}"
	end

	def invoice_return_discount
		"#{number_with_precision @invoice_return.discount, :precision=>2 }"
	end

	def invoice_return_tax_amount
		amt = 0
		@invoice_return.tax_line_items.each do |line_item|
			tax_account= line_item.account
			next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
			amt+= line_item.amount
		end
		"#{number_with_precision amt,:precision =>2}"
	end
	
	def invoice_return_currncy
		@currency||=@invoice_return.currency
	end
end
