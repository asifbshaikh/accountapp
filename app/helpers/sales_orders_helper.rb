module SalesOrdersHelper
def sales_order_line_count
	count=4
	count+=1 if @sales_order.get_discount>0
	count+=2 if @sales_order.has_tax_lines?
	count
end
def sales_order_status_badge
      "info"
 end

def sales_order_billing_status_badge
      "success"
end
end