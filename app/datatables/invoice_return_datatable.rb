class InvoiceReturnDatatable
	include Rails.application.routes.url_helpers
	include ActionView::Helpers
	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
	delegate :params, :h, :link_to, :format_amt_with_currency, :number_to_currency, :to => :@view

	def initialize(view, company, user, financial_year)
	  @view =view
	  @company = company
	  @user=user
	  @financial_year = financial_year
	end

	def as_json(options ={})
	  {
	    :sEcho => params[:sEcho].to_i,
	    :iTotalRecords => invoice_returns.count,
	    :iTotalDisplayRecords => invoice_returns.total_count,
	    :aaData => data
	  }
	end

	private

    def data
      invoice_returns.map do |invoice_return|
        [
          link_to(invoice_return.invoice_return_number, invoice_return_path(invoice_return)),
          link_to(invoice_return.invoice.invoice_number, invoice_path(invoice_return.invoice)),
          h(invoice_return.account.name),
          h(invoice_return.record_date),
          format_amt_with_currency(invoice_return.currency, invoice_return.total_amount),
          send("#{InvoiceReturn::ALLOCATION_STATUS[invoice_return.is_credit_note_allocated?]}_twitter_dropdown",invoice_return)
        ]
      end
    end

  def non_allocated_twitter_dropdown(invoice_return)
    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
      b.bootstrap_button "View", invoice_return_path(invoice_return),  :class => "btn btn-white  dropdown-toggle btn-sm"
      b.link_to "Edit", edit_invoice_return_path(invoice_return) unless invoice_return.in_frozen_year?
      b.link_to "Allocate Amount", "/credit_notes/allocate?id=#{invoice_return.credit_note.id}" if invoice_return.allocation_enable?
      b.link_to "Export to PDF", invoice_return_path(invoice_return, :format => "pdf"), :target=>"_blank"
      b.content_tag :li,"",:class => "divider" unless invoice_return.in_frozen_year?
      b.link_to "Delete", invoice_return, :method => "delete", :confirm =>"Are you sure?"  unless invoice_return.in_frozen_year?
    end
  end

  def allocated_twitter_dropdown(invoice_return)
    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
      b.bootstrap_button "View", invoice_return_path(invoice_return),  :class => "btn btn-white  dropdown-toggle btn-sm"
      b.link_to "Allocate Amount", "/credit_notes/allocate?id=#{invoice_return.credit_note.id}" if invoice_return.allocation_enable?
      b.link_to "Export to PDF", invoice_return_path(invoice_return, :format => "pdf"), :target=>"_blank"
    end
  end

  def invoice_returns
  	@invoice_returns ||= fetch_invoice_returns
  end

  def fetch_invoice_returns
    if params[:sSearch].present?
	  	search_params = "%#{params[:sSearch]}%"
      @customer_ids = Account.get_account_ids(@company,search_params)
      invoice_returns = @company.invoice_returns.where("invoice_return_number like ? or total_amount like ? or record_date like ? or account_id in (?)", search_params, search_params, search_params, @customer_ids)
    elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
      invoice_returns = search_invoice_returns
    else
      invoice_returns = @company.invoice_returns#.this_year_and_previous_unpaid(@financial_year.start_date, @financial_year.end_date)
    end
    invoice_returns = invoice_returns.order("#{sort_column} #{sort_direction}")
    invoice_returns.page(page).per(per_page)
  end

  def search_invoice_returns
    results = Array.new
  	date_range=params[:sSearch_2].split("~")
  	start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
  	end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

    if !params[:sSearch_5].blank?
    	amount_range=params[:sSearch_5].split("~")
    	min_amt = amount_range[0].blank? ? 0 : amount_range[0]
    	max_amt = amount_range[1].blank? ? (@company.invoice_returns.maximum(:total_amount)) : amount_range[1]
    else
    	min_amt = 0
    	max_amt = @company.invoice_returns.maximum(:total_amount)
    end
    begin
	    results = @company.invoice_returns#.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
    rescue ArgumentError => e
	    results = @company.invoice_returns#.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date)
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
    columns = %w[invoice_return_number invoice_id account_id record_date total_amount created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "asc" : "desc"
  end

end