class SalesOrderTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :sales_order_line_item
end
