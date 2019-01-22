class TdsPaymentVoucherDatatable
	include Rails.application.routes.url_helpers
	include ActionView::Helpers
	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
	delegate :params, :h, :link_to, :number_to_currency, :to => :@view

	def initialize(view, company, user, financial_year)
	  @view =view
	  @company = company
	  @user=user
	  @financial_year = financial_year
	end

	def as_json(options ={})
	  {
	    :sEcho => params[:sEcho].to_i,
	    :iTotalRecords => tds_payment_vouchers.count,
	    :iTotalDisplayRecords => tds_payment_vouchers.total_count,
	    :aaData => data
	  }
	end

	private
	  def data

		    tds_payment_vouchers.map do |tds_payment_voucher|
		      [
		        link_to(tds_payment_voucher.challan_no, tds_payment_voucher_path(tds_payment_voucher)),
		        h(tds_payment_voucher.payment_date.strftime("%d-%m-%Y")),
		        h(FinancialYear.find(tds_payment_voucher.assessment_year).year.name),
		        h(tds_payment_voucher.payment_detail.payment_mode),
		        format_currency(tds_payment_voucher.amount),
		        twitter_dropdown(tds_payment_voucher)
		      ]
		    end
	  end

	  def twitter_dropdown(tds_payment_voucher)

	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white dropdown-toggle btn-sm"}) do |b|
	        b.bootstrap_button "View", tds_payment_voucher_path(tds_payment_voucher),  :class => "btn btn-white  dropdown-toggle btn-sm"
	        b.link_to "Edit", edit_tds_payment_voucher_path(tds_payment_voucher)
	        # b.link_to "Export to PDF", tds_payment_voucher_path(tds_payment_voucher, :format => "pdf")
	        b.content_tag :li,"",:class => "divider"
	        b.link_to "Delete", tds_payment_voucher, :method => "delete", :confirm =>"Are you sure?"
	    end
	end

	  def voucher_detail(tds_payment_voucher)
	  	content_tag :a, tds_payment_voucher.challan_no, :"data-toggle" =>"popover", :"data-html"=> "true", :"data-placement" =>"right",
	  	 :"data-content" =>"Hi", :"data-original-title"=>'X'
	  end

	  def tds_payment_vouchers
	  	if params[:vendor].present?
	    	@tds_payment_vouchers ||= fetch_vendor_tds_payment_vouchers
	    else
	    	@tds_payment_vouchers ||= fetch_tds_payment_vouchers
	    end
	  end
	  def fetch_vendor_tds_payment_vouchers
	  	if params[:sSearch].present?
	  	  #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	  	  tds_payment_vouchers = @company.tds_payment_vouchers.where("(challan_no like :search or payment_date like :search or assessment_year like :search)", :search => "%#{params[:sSearch]}%")
	  	elsif params[:sSearch_0].present?
	  	  tds_payment_vouchers = search_tds_payment_vouchers
	  	else
	  	  tds_payment_vouchers = @company.tds_payment_vouchers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year)
	  	end
	  	tds_payment_vouchers.order("voucher_date DESC").page(page).per(per_page)
	  end
	  def fetch_tds_payment_vouchers
	    if params[:sSearch].present?
	      #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	      tds_payment_vouchers = @company.tds_payment_vouchers.where("(challan_no like :search or payment_date like :search or assessment_year like :search)", :search => "%#{params[:sSearch]}%")
	    elsif params[:sSearch_0].present?
	      tds_payment_vouchers = search_tds_payment_vouchers
	    else
	      tds_payment_vouchers = @company.tds_payment_vouchers.by_branch_id(@user.branch_id).by_date(@financial_year)
	    end
	    tds_payment_vouchers.order("payment_date DESC").page(page).per(per_page)
	  end

	  def search_tds_payment_vouchers
	    results = Array.new
	    if params[:sSearch_0].present?
	      # results = @company.customers.where("name like ?", "%#{params[:sSearch_0]}%")
	    end
	    results
	  end
	  def page
	    params[:iDisplayStart].to_i / per_page + 1
	  end

	  def per_page
	    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
	  end

	  def sort_column
	    columns = %w[name created_by]
	    columns[params[:iSortCol_0].to_i]
	  end

	  def sort_direction
	    params[:sSortDir_0] == "desc" ? "desc" : "asc"
	  end

	  def format_currency(amt)
	    unit = @company.country.currency_code
	    number_to_currency(amt, :unit => unit+" ", :precision=> 2)
	  end
end