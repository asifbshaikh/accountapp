class GstrAdvanceReceiptTax < ActiveRecord::Base
	belongs_to :gstr_advance_receipt_line_item

	belongs_to :account
	attr_accessible  :account_id
	
end