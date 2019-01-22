class StockTransferVoucherDatatable
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
	    :iTotalRecords => stock_transfer_vouchers.count,
	    :iTotalDisplayRecords => stock_transfer_vouchers.total_count, 
	    :aaData => data
	  }
	end

	private
	  def data
	    data_arr=[]
	    stock_transfer_vouchers.map do |stock_transfer_voucher|
	    	[
	    		link_to(stock_transfer_voucher.voucher_number, stock_transfer_voucher),
	    		stock_transfer_voucher.transfer_date,
	    		stock_transfer_voucher.warehouse_name,
	    		truncate(stock_transfer_voucher.details, :length => 20),
	    		stock_transfer_voucher.created_by_user,
	    		twitter_dropdown(stock_transfer_voucher)
	    	]
	    end
	  end

	  def twitter_dropdown(stock_transfer_voucher)
	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
	      b.bootstrap_button "View", stock_transfer_voucher_path(stock_transfer_voucher),  :class => "btn btn-white btn-sm dropdown-toggle"
	      b.link_to "Edit", edit_stock_transfer_voucher_path(stock_transfer_voucher) unless stock_transfer_voucher.in_frozen_year?
	      b.link_to "Export to Pdf", stock_transfer_voucher_path(stock_transfer_voucher, :format => "pdf"), :target=> "_blank"
	      b.content_tag :li,"",:class => "divider" unless stock_transfer_voucher.in_frozen_year?
	      b.link_to "Delete", stock_transfer_voucher, :method => "delete", :confirm =>"Are you sure?" unless stock_transfer_voucher.in_frozen_year?
	     end      
	  end

	  def stock_transfer_vouchers
	    @stock_transfer_vouchers ||= fetch_stock_transfer_vouchers
	  end

	  def fetch_stock_transfer_vouchers
	    if params[:sSearch].present?
	      stock_transfer_vouchers = @company.stock_transfer_vouchers.where("voucher_date like :search or voucher_number like :search", :search=>"%#{params[:sSearch]}%").by_branch_id(@user.branch_id).by_date(@financial_year)
	    # elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
	    #   invoices =  search_invoices
	    else
	      stock_transfer_vouchers = @company.stock_transfer_vouchers.by_branch_id(@user.branch_id)# .by_date(@financial_year)
	    end
	    stock_transfer_vouchers = stock_transfer_vouchers.order("#{sort_column} #{sort_direction}")
	    stock_transfer_vouchers = stock_transfer_vouchers.page(page).per(per_page)
	  end

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