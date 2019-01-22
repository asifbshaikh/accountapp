class SalesOrderReportsController < ApplicationController

  def customer_wise_so
    @page_name = "#{@company.label.customer_label} Wise Pending/Unexecuted Order"
    @customers = @company.customers
    unless @customers.blank?
      start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @customer=@company.customers.find_by_id(params[:customer_id].to_i)
      @sales_orders = @company.sales_orders.by_status([1,2]).by_branch_id(@current_user.branch_id).by_customer(params[:customer_id]).by_date_range(start_date, end_date)
    end
    prawnto :filename => "#{@company.label.customer_label}_wise_so.pdf"
  end

  def product_wise_so
    @page_name = "Product Wise Pending/Unexecuted Order"
    @products = Product.get_sales_order_products(@company.id)
    unless @products.blank?
      start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @product= params[:product_id].blank? ? @products.first : @company.products.find_by_id(params[:product_id].to_i)
      @sales_order_line_items = SalesOrderLineItem.where(:product_id=> @product.id).joins(:sales_order).where("sales_orders" =>{:company_id => @company.id, :status => [1,2], :branch_id => @current_user.branch_id, :voucher_date => start_date..end_date})
    end
    prawnto :filename => "Product_wise_so.pdf"
  end

  def pending_invoices_for_dc
    @page_name = "Pending Invoice For Delivery Challan "
    @customers = @company.customers
    unless @customers.blank?
      start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @customer=@company.customers.find_by_id(params[:customer_id].to_i)
      if !@current_user.branch_id.blank?
        @delivery_challans = DeliveryChallan.joins(:sales_order)
          .where("sales_orders" => {:company_id => @company.id, :status=>[2,3], :billing_status=> 0, :branch_id=>@current_user.branch_id, :voucher_date=> start_date..end_date})
          .by_customer(params[:customer_id])
      else
        @delivery_challans = DeliveryChallan.joins(:sales_order)
          .where("sales_orders" => {:company_id => @company.id, :status=>[2,3], :billing_status=> 0, :voucher_date=> start_date..end_date})
          .by_customer(params[:customer_id])
      end
    end
    prawnto :filename => "Pending_invoice_for_dc.pdf"
  end

end
