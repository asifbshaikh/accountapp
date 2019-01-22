class PurchaseDatatable
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
	    :iTotalRecords => purchases.count,
	    :iTotalDisplayRecords => purchases.total_count,
	    :aaData => data
	  }
	end

	private
	  def data
	  	if params[:vendor].present?
	  		purchases.map do |purchase|
	  		  [
	  		    link_to(purchase.purchase_number, purchase_path(purchase)),
	  		    h(purchase.record_date),
	  		    h(purchase.due_date),
	  		    "#{purchase.currency} #{format_amount(purchase.total_amount)}",
	  		    h(purchase.get_status),
	  		  ]
	  		end
      elsif params[:project].present?
        	purchases.map do |purchase|
	  		  [
	  		    link_to(purchase.purchase_number, purchase_path(purchase)),
	  		     h(purchase.account.name),
	  		    h(purchase.due_date),
	  		    "#{purchase.currency} #{format_amount(purchase.total_amount - purchase.total_returned) }",
	  		    purchase.created_by_user
	  		  ]
	  		end
	  	elsif params[:status_id].present?
	  		purchases.map do |purchase|
		  		[
		  		  link_to(purchase.purchase_number, edit_purchase_path(purchase)),
		  		  h(purchase.vendor_name),
		  		  h(purchase.due_date),
		  		  "#{purchase.currency} #{format_amount(purchase.total_amount)}",
		  		  h(purchase.get_status),
		  		  !purchase.project_id.blank? ? purchase.project_name : "Not assigned" ,
		  		  draft_twitter_dropdown(purchase)
		  		]
		  	end
	  	else
		    purchases.map do |purchase|
		      [
		        link_to(purchase.purchase_number, purchase_path(purchase)),
		        h(purchase.record_date),
		        h(purchase.account.name),
		        h(purchase.due_date),
		        "#{purchase.currency} #{format_amount(purchase.total_amount)}",
		        h(purchase.get_status),
		        !purchase.project_id.blank? ? purchase.project_name : "Not assigned" ,
		        twitter_dropdown(purchase)
		      ]
		    end
		  end
	  end

	  def twitter_dropdown(purchase)
	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
        b.bootstrap_button "View", purchase_path(purchase),  :class => "btn btn-white  dropdown-toggle btn-sm"
        b.link_to "Edit", edit_purchase_path(purchase) unless purchase.in_frozen_year? || purchase.has_return_any?
        b.link_to "Return this purchase", new_purchase_return_path(:purchase_id=>purchase.id)
        b.link_to "Export to PDF", purchase_path(purchase, :format => "pdf"), :target=>"_blank"
        b.content_tag :li,"",:class => "divider" unless purchase.in_frozen_year?
        b.link_to "Delete", purchase, :method => "delete", :confirm =>"Are you sure?"  unless purchase.in_frozen_year? || purchase.has_return_any?
	    end
	  end

	  def draft_twitter_dropdown(purchase)
	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
        b.bootstrap_button "Edit", edit_purchase_path(purchase),  :class => "btn btn-white  dropdown-toggle btn-sm"
        b.link_to "Delete", purchase, :method => "delete", :confirm =>"Are you sure?"
	    end
	  end

	  def purchases
	  	if params[:vendor].present?
	  		@purchases ||= fetch_vendor_purchases
	    elsif params[:project].present?
	    	@purchases ||= fetch_project_purchases
	    elsif params[:status_id].present?
	    	@purchases ||= fetch_draft_purchases
	    else
	    	@purchases ||= fetch_purchases
	    end
	  end

	  def fetch_draft_purchases
	    if params[:sSearch].present?
		  	search_params = "%#{params[:sSearch]}%"
	      @vendor_ids = Account.get_account_ids(@company,search_params)
	      @project_ids = Project.get_project_ids(@company,search_params)
	      purchases = @company.purchases.where("purchase_number like ? or total_amount like ? or due_date like ? or account_id in (?) or project_id in (?) or status_id = ?", search_params, search_params, search_params, @vendor_ids, 2, @status_id)
	    else
	      purchases = @company.purchases.by_branch_id(@user.branch_id).by_deleted(false).by_status(2)#.this_year_and_previous_unpaid(@financial_year.start_date, @financial_year.end_date)
	    end
	    purchases = purchases.order("#{sort_column} #{sort_direction}")
	    purchases.page(page).per(per_page)
	  end

	  def fetch_vendor_purchases
	    if params[:sSearch].present?
	      purchases = @company.purchases.where("(purchase_number like :search or total_amount like :search) and account_id=#{params[:vendor].to_i}", :search => "%#{params[:sSearch]}%")
	    else
	      purchases = @company.purchases.where(:account_id=>params[:vendor].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	    end
	    purchases = purchases.order("#{sort_column} #{sort_direction}")
	    purchases.page(page).per(per_page)
	  end

	  def fetch_purchases
	    if params[:sSearch].present?
		  	search_params = "%#{params[:sSearch]}%"
	      @vendor_ids = Account.get_account_ids(@company,search_params)
	      @project_ids = Project.get_project_ids(@company,search_params)
	      @status_id = Purchase.get_status_id(search_params)
	      purchases = @company.purchases.where("purchase_number like ? or total_amount like ? or due_date like ? or account_id in (?) or project_id in (?) or status_id = ?", search_params, search_params, search_params, @vendor_ids, @project_ids, @status_id)
	    elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
	      purchases = search_purchases
	    else
	      purchases = @company.purchases.by_branch_id(@user.branch_id).by_deleted(false)#.by_status([0, 1])#.this_year_and_previous_unpaid(@financial_year.start_date, @financial_year.end_date)
	    end
	    purchases = purchases.order("#{sort_column} #{sort_direction}")
	    purchases.page(page).per(per_page)
	  end

    def fetch_project_purchases
	    if params[:sSearch].present?
	      purchases = @company.purchases.where("(purchase_number like :search or total_amount like :search) and project_id=#{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
	    else
	      purchases = @company.purchases.by_project(params[:project]).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	    end
	    purchases = purchases.order("#{sort_column} #{sort_direction}")
	    purchases.page(page).per(per_page)
    end

	  def search_purchases
	    results = Array.new
    	date_range=params[:sSearch_2].split("~")
    	start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
    	end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

	    if !params[:sSearch_5].blank?
	    	amount_range=params[:sSearch_5].split("~")
	    	min_amt = amount_range[0].blank? ? 0 : amount_range[0]
	    	max_amt = amount_range[1].blank? ? (@company.purchases.maximum(:total_amount)) : amount_range[1]
	    else
	    	min_amt = 0
	    	max_amt = @company.purchases.maximum(:total_amount)
	    end
	    begin
		    results = @company.purchases.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
	    rescue ArgumentError => e
		    results = @company.purchases.by_deleted(false).by_voucher(params[:sSearch_0]).by_vendor(params[:sSearch_1]).by_status(params[:sSearch_3]).by_project(params[:sSearch_4]).by_date_range(start_date, end_date)
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
	    columns = %w[id account_id due_date total_amount status_id project_id purchase_number]
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