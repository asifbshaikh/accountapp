class InvoiceReturnTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :invoice_return_line_item
end
