module PaymentVouchersHelper
	def payment_against
		if @payment_voucher.against_expense?
			if request.format=="html"
				link_to @payment_voucher.expense.voucher_number, @payment_voucher.expense
			else
				@payment_voucher.expense.voucher_number
			end
		elsif @payment_voucher.against_purchase?
			@payment_voucher.purchase.purchase_number
		else
			"Not against any voucher"
		end
	end
end
