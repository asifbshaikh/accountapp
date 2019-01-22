class PurchaseOrderTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :purchase_order_line_item
end
