class InvoiceTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :invoice_line_item
	belongs_to :time_line_item
end
