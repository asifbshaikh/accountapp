module PurchaseReturnsHelper
	def purchase_return_line_applied_taxes(purchase_return_line_item)
		names=""
		purchase_return_line_item.purchase_return_taxes.each do |tax|
			unless tax.account.blank? 
				names+= ", " if purchase_return_line_item.purchase_return_taxes.last.equal?(tax) && !purchase_return_line_item.purchase_return_taxes.first.equal?(tax)
				names+= tax.account.name.chomp('on purchase')
			end
		end
		names
	end

	def fy_specific_header
		if @purchase_return.in_frozen_year?
			"frozen_header"
		else
			"unfreeze_header"
		end
	end

	def purchase_return_sub_total
		"#{purchase_return_currncy} #{format_amount(@purchase_return.purchase_return_line_items.sum(:amount))}"
	end

	def purchase_return_discount
		"#{purchase_return_currncy} #{format_amount(@purchase_return.discount)}"
	end

	def purchase_return_tax_amount
		amt=0
		@purchase_return.tax_line_items.each do |line_item|
					 tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
   		end
	amt
		# "#{purchase_return_currncy} #{@purchase_return.tax_line_items.sum(:amount)}"
	end
	
	def purchase_return_currncy
		@currency||=@purchase_return.currency
	end
end
