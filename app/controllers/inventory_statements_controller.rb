class InventoryStatementsController < ApplicationController

  def stock_statement
  	@start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
  	@end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
  	@branch_id=params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @all_products = @company.products
    @tags = @all_products.tag_counts_on(:tags)    
    service = StockSummaryService.new @company, @current_user, params[:category]
    @stock_summaries = service.stock_summary(@start_date, @end_date, @branch_id)
  	respond_to do |format|
  		format.html
  		format.xls
  		format.pdf do
  			pdf = StockStatementPdf.new(view_context, @company, @stock_summaries, @start_date, @end_date, @branch_id)
  			send_data pdf.render, :filename=>"stock_summary.pdf", :disposition=>"inline", :type=>"application/pdf"
  		end
  	end
  end

  def product_statement
    @start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @products = @company.products
    unless @products.blank?
      product_id= params[:product_id].blank? ? @products.first.id : params[:product_id].to_i
      @product = @products.find_by_id(product_id)
      @purchase_line_items=PurchaseLineItem.by_product_and_date_range(product_id, @start_date, @end_date, @branch_id)
      @invoice_line_items=InvoiceLineItem.by_product_and_date_range(product_id, @start_date, @end_date, @branch_id)
      @stocks_data = StockProduct.new(@product, @start_date, @end_date, @branch_id)
    end
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf = ProductStatementPdf.new(view_context, @company, @product, @stocks_data, @purchase_line_items, @invoice_line_items, @start_date, @end_date, @branch_id)
        send_data pdf.render, :filename=>"product_statement.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

  def date_limit_error
    flash[:error] = "The closing date cannot be earlier than the opening date"
    redirect_to :action=> :index
  end

  private
    def find_products(params)
      if params[:category].present?
        @company.products.tagged_with(params[:category])
      elsif params[:product_id].present?
        @company.products.find_by_id(params[:product_id])
      else
        @company.products 
      end  
    end

end
