class GstrAdvancePaymentTax < ActiveRecord::Base
	belongs_to :gstr_advance_payment_line_item
    belongs_to :account
    attr_accessible :account_id
end
