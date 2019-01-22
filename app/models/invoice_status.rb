class InvoiceStatus < ActiveRecord::Base
	has_many	:invoices
end
