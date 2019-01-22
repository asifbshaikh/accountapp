class PurchasesPayment < ActiveRecord::Base
	belongs_to :purchase
	belongs_to :payment_voucher
end
