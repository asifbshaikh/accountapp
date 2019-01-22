class PurchaseReturnDatatable
	include Rails.application.routes.url_helpers
	include ActionView::Helpers
	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
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
	    :iTotalRecords => purchase_returns.count,
	    :iTotalDisplayRecords => purchase_returns.total_count,
	    :aaData => data
	  }
	end

	private
  def data
    purchase_returns.map do |purchase_return|
      [
        link_to(purchase_return.purchase_return_number, purchase_return_path(purchase_return)),
        link_to(purchase_return.purchase.purchase_number, purchase_path(purchase_return.purchase)),
        h(purchase_return.account.name),
        h(purchase_return.record_date),
        "#{format_amt_with_currency(purchase_return.currency,purchase_return.total_amount)}",
        send("#{PurchaseReturn::ALLOCATION_STATUS[purchase_return.is_debit_note_allocated?]}_twitter_dropdown",purchase_return)
      ]
    end
  end

  def non_allocated_twitter_dropdown(purchase_return)
    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
      b.bootstrap_button "View", purchase_return_path(purchase_return),  :class => "btn btn-white  dropdown-toggle btn-sm"
      b.link_to "Edit", edit_purchase_return_path(purchase_return) unless purchase_return.in_frozen_year?
      b.link_to "Allocate Amount", "/debit_notes/allocate?id=#{purchase_return.debit_note.id}" if purchase_return.allocation_enable?
      b.link_to "Export to PDF", purchase_return_path(purchase_return, :format => "pdf"), :target=>"_blank"
      b.content_tag :li,"",:class => "divider" unless purchase_return.in_frozen_year?
      b.link_to "Delete", purchase_return, :method => "delete", :confirm =>"Are you sure?"  unless purchase_return.in_frozen_year?
    end
  end
  def allocated_twitter_dropdown(purchase_return)
    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
      b.bootstrap_button "View", purchase_return_path(purchase_return),  :class => "btn btn-white  dropdown-toggle btn-sm"
      b.link_to "Allocate Amount", "/debit_notes/allocate?id=#{purchase_return.debit_note.id}" if purchase_return.allocation_enable?
      b.link_to "Export to PDF", purchase_return_path(purchase_return, :format => "pdf"), :target=>"_blank"
    end
  end

  def purchase_returns
  	@purchase_returns ||= fetch_purchase_returns
  end

  def fetch_purchase_returns
    if params[:sSearch].present?
	  	search_params = "%#{params[:sSearch]}%"
      @vendor_ids = Account.get_account_ids(@company,search_params)
      purchase_returns = @company.purchase_returns.where("purchase_return_number like ? or total_amount like ? or record_date like ? or account_id in (?)", search_params, search_params, search_params, @vendor_ids)
    elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
      purchase_returns = search_purchase_returns
    else
      purchase_returns = @company.purchase_returns#.this_year_and_previous_unpaid(@financial_year.start_date, @financial_year.end_date)
    end
    purchase_returns = purchase_returns.order("#{sort_column} #{sort_direction}")
    purchase_returns.page(page).per(per_page)
  end

  def search_purchase_returns
    results = Array.new
  	date_range=params[:sSearch_2].split("~")
  	start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
  	end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

    if !params[:sSearch_5].blank?
    	amount_range=params[:sSearch_5].split("~")
    	min_amt = amount_range[0].blank? ? 0 : amount_range[0]
    	max_amt = amount_range[1].blank? ? (@company.purchase_returns.maximum(:total_amount)) : amount_range[1]
    else
    	min_amt = 0
    	max_amt = @company.purchase_returns.maximum(:total_amount)
    end
    begin
	    results = @company.purchase_returns#.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
    rescue ArgumentError => e
	    results = @company.purchase_returns#.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date)
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
    columns = %w[purchase_return_number purchase_id account_id record_date total_amount created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "asc" : "desc"
  end

  def format_currency(amt)
    unit = @company.country.currency_code
    number_to_currency(amt, :unit => unit+" ", :precision=> 2)
  end
end