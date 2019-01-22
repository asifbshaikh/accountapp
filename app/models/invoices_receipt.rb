class InvoicesReceipt < ActiveRecord::Base
	belongs_to :invoice
	belongs_to :receipt_voucher
end
