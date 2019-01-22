class ExpensesPayment < ActiveRecord::Base
	belongs_to :expense
	belongs_to :payment_voucher
end
