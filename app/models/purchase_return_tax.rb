class PurchaseReturnTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :purchase_return_line_item
end
