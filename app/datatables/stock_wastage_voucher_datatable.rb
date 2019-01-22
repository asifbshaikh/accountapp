class StockWastageVoucherDatatable
	include Rails.application.routes.url_helpers 
	include ActionView::Helpers
	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
	delegate :params, :h, :link_to, :number_to_currency, :to => :@view

	def initialize(view, company, user, financial_year)
	  @view =view
	  @company = company
	  @user = user
	  @financial_year = financial_year
	end

	def as_json(options ={})
	  {
	    :sEcho => params[:sEcho].to_i,
	    :iTotalRecords => stock_wastage_vouchers.count,
	    :iTotalDisplayRecords => stock_wastage_vouchers.total_count, 
	    :aaData => data
	  }
	end

	private
	  def data
	    data_arr=[]
	    stock_wastage_vouchers.map do |stock_wastage_voucher|
	    	[
	    		link_to(stock_wastage_voucher.voucher_number, stock_wastage_voucher),
	    		stock_wastage_voucher.voucher_date.to_date,
	    		stock_wastage_voucher.warehouse.name,
	    		stock_wastage_voucher.created_by_user,
	    		twitter_dropdown(stock_wastage_voucher)
	    	]
	    end
	  end

	  def twitter_dropdown(stock_wastage_voucher)
	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
	      b.bootstrap_button "View", stock_wastage_voucher_path(stock_wastage_voucher),  :class => "btn btn-white btn-sm dropdown-toggle"
	      b.link_to "Edit", edit_stock_wastage_voucher_path(stock_wastage_voucher) unless stock_wastage_voucher.in_frozen_year?
	      b.link_to "Export to Pdf", stock_wastage_voucher_path(stock_wastage_voucher, :format => "pdf"), :target=> "_blank"
	      b.content_tag :li,"",:class => "divider" unless stock_wastage_voucher.in_frozen_year?
	      b.link_to "Delete", stock_wastage_voucher, :method => "delete", :confirm =>"Are you sure?" unless stock_wastage_voucher.in_frozen_year?
	     end      
	  end

	  def stock_wastage_vouchers
	    @stock_wastage_vouchers ||= fetch_stock_wastage_vouchers
	  end

	  def fetch_stock_wastage_vouchers
	    if params[:sSearch].present?
	      stock_wastage_vouchers = @company.stock_wastage_vouchers.where("voucher_date like :search or voucher_number like :search", :search=>"%#{params[:sSearch]}%").by_branch_id(@user.branch_id).by_date(@financial_year)
	    # elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
	    #   invoices =  search_invoices
	    else
	      stock_wastage_vouchers = @company.stock_wastage_vouchers.by_branch_id(@user.branch_id)# .by_date(@financial_year)unless stock_wastage_voucher.in_frozen_year?
	    end
	    stock_wastage_vouchers = stock_wastage_vouchers.order("#{sort_column} #{sort_direction}")
	    stock_wastage_vouchers = stock_wastage_vouchers.page(page).per(per_page)
	  end

	  # def search_invoices
	  #   results = Array.new

	  #   if !params[:sSearch_2].blank?
	  #     date_range=params[:sSearch_2].split("~")
	  #     start_date= date_range[0].blank? ? @financial_year.start_date : date_range[0].to_date
	  #     end_date= date_range[1].blank? ? @financial_year.end_date : date_range[1].to_date
	  #   else
	  #     start_date=@financial_year.start_date
	  #     end_date=@financial_year.end_date
	  #   end

	  #   if !params[:sSearch_3].blank?
	  #     amount_range=params[:sSearch_3].split("~")
	  #     min_amt=amount_range[0].blank? ? 0 : amount_range[0]
	  #     max_amt=amount_range[1].blank? ? (@company.invoices.maximum(:total_amount)) : amount_range[1]
	  #   else
	  #     min_amt = 0
	  #     max_amt = @company.invoices.maximum(:total_amount)
	  #   end
	  #   Rails.logger.info"+++ min_amt=#{min_amt} max_amt=#{max_amt}"
	  #   results = @company.invoices.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_project(params[:sSearch_5]).by_amount_range(min_amt, max_amt)
	  #   results
	  # end

	  def page
	    params[:iDisplayStart].to_i / per_page + 1
	  end

	  def per_page
	    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
	  end

	  def sort_column
	    columns = %w[voucher_number voucher_date]
	    columns[params[:isortCol_0].to_i]
	  end

	  def sort_direction
	    params[:sSortDir_0] == "desc" ? "asc" : "desc"
	  end
	  def format_currency(amt)
	    unit = @company.country.currency_code
	    number_to_currency(amt, :unit => unit+" ", :precision=> 2)   
	  end
end