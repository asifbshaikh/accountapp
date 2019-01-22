class SalesReportsController < ApplicationController

  def sales_by_customer
 	@menu = "Reports"
    @page_name = "Sales By Customer"
    
	prawnto :filename => "sales_by_customer.pdf"
 end

  def sales_by_item
  	@menu = "Reports"
    @page_name = "Sales By Item"
    
	prawnto :filename => "sales_by_item.pdf"
  end

end
