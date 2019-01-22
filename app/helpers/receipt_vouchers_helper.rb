module ReceiptVouchersHelper
	def receipt_voucher_amount(object)
		object.foreign_currency? ? object.amount*object.exchange_rate : object.amount
	end
end
