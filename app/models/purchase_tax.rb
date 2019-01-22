class PurchaseTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :purchase_line_item
end
