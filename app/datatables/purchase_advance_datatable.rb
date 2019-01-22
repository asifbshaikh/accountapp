class PurchaseAdvanceDatatable
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
	    :iTotalRecords => purchase_advances.count,
	    :iTotalDisplayRecords => purchase_advances.total_count, 
	    :aaData => data
	  }
	end

	private
	  def data
	  	if params[:vendor].present?
				purchase_advances.map do |purchase_advance|
		      [
		        link_to(purchase_advance.voucher_number, purchase_advance_path(purchase_advance)),
		        h(purchase_advance.voucher_date),
		        "#{purchase_advance.currency} #{number_with_precision purchase_advance.amount, :precision=>2}",
		        h(purchase_advance.payment_detail.payment_mode),
		      ]
		    end
	  	else
		    purchase_advances.map do |purchase_advance|
		      [
		        link_to(purchase_advance.voucher_number, purchase_advance_path(purchase_advance)),
		        h(purchase_advance.voucher_date),
		        h(purchase_advance.to_account_name),
		        "#{purchase_advance.currency} #{number_with_precision purchase_advance.amount, :precision=>2}",
		        h(purchase_advance.payment_detail.payment_mode),
		        twitter_dropdown(purchase_advance)
		      ]
		    end
		  end
	  end

	  def twitter_dropdown(purchase_advance)

	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white dropdown-toggle btn-sm"}) do |b|
	        b.bootstrap_button "View", purchase_advance_path(purchase_advance),  :class => "btn btn-white  dropdown-toggle btn-sm"
	        b.link_to "Allocate Amount", "/purchase_advances/allocate?id=#{purchase_advance.id}" if purchase_advance.advance_payment? 
	        b.link_to "Edit", edit_purchase_advance_path(purchase_advance) unless purchase_advance.in_frozen_year?
	        b.link_to "Export to PDF", purchase_advance_path(purchase_advance, :format => "pdf"), :target=>"_blank"
	        b.content_tag :li,"",:class => "divider" unless purchase_advance.in_frozen_year?
	        b.link_to "Delete", purchase_advance, :method => "delete", :confirm =>"Are you sure?"  unless purchase_advance.in_frozen_year?
	    end      
	  end

	  def voucher_detail(purchase_advance)
	  	content_tag :a, purchase_advance.voucher_number, :"data-toggle" =>"popover", :"data-html"=> "true", :"data-placement" =>"right",
	  	 :"data-content" =>"Hi", :"data-original-title"=>'X'
	  end

	  def purchase_advances
	  	if params[:vendor].present?
	    	@purchase_advances ||= fetch_vendor_purchase_advances
	    elsif params[:voucher_type].present?
	    	@purchase_advances ||= send("fetch_#{PaymentVoucher::PAYMENT_OPTION[params[:voucher_type].to_i]}")
	    else
	    	@purchase_advances ||= fetch_purchase_advances
	    end
	  end

	  def fetch_advance_payment
	  	if params[:sSearch].present?
				search_params = "%#{params[:sSearch]}%"
				@account_ids = Account.get_account_ids(@company,search_params)
				purchase_advances = @company.purchase_advances.by_voucher_type(1).joins(:payment_detail).where("purchase_advances.voucher_number like ? or purchase_advances.amount like ? or purchase_advances.voucher_date like ? or payment_details.type like ? or purchase_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)	  		
	  	else
		  	purchase_advances = @company.purchase_advances.by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(1)
		  end
		  purchase_advances = purchase_advances.order("#{sort_column} #{sort_direction}")
	  	purchase_advances.page(page).per(per_page)
	  end

	  def fetch_other_payment
	  	if params[:sSearch].present?
				search_params = "%#{params[:sSearch]}%"
				@account_ids = Account.get_account_ids(@company,search_params)
				purchase_advances = @company.purchase_advances.by_voucher_type(2).joins(:payment_detail).where("purchase_advances.voucher_number like ? or purchase_advances.amount like ? or purchase_advances.voucher_date like ? or payment_details.type like ? or purchase_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)	  		
	  	else
		  	purchase_advances = @company.purchase_advances.by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(2)
		  end
		  purchase_advances = purchase_advances.order("#{sort_column} #{sort_direction}")
	  	purchase_advances.page(page).per(per_page)
	  end

	  def fetch_vendor_purchase_advances
	  	if params[:sSearch].present?
	  	  #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	  	  purchase_advances = @company.purchase_advances.where("(voucher_number like :search or amount like :search) and to_account_id=#{params[:vendor].to_i}", :search => "%#{params[:sSearch]}%")
	  	elsif params[:sSearch_0].present? 
	  	  purchase_advances = search_purchase_advances
	  	else
	  	  purchase_advances = @company.purchase_advances.where(:to_account_id=>params[:vendor].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	  	end
	  	purchase_advances = purchase_advances.order("#{sort_column} #{sort_direction}")
	  	purchase_advances.page(page).per(per_page)
	  end
	  def fetch_purchase_advances
	    if params[:sSearch].present?
	      #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	      search_params = "%#{params[:sSearch]}%"
	      @account_ids = Account.get_account_ids(@company,search_params)
	      purchase_advances = @company.purchase_advances.by_voucher_type(0).joins(:payment_detail).where("purchase_advances.voucher_number like ? or purchase_advances.amount like ? or purchase_advances.voucher_date like ? or payment_details.type like ? or purchase_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)
	    elsif params[:sSearch_0].present?|| params[:sSearch_1].present? || params[:sSearch_2].present?||params[:sSearch_3].present?||params[:sSearch_4].present?
	      purchase_advances = search_purchase_advances
	    else
	      purchase_advances = @company.purchase_advances.by_voucher_type(0).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	    end
	    purchase_advances = purchase_advances.order("#{sort_column} #{sort_direction}")
	    purchase_advances.page(page).per(per_page)
	  end

	  def search_purchase_advances
      results = Array.new
      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.purchase_advances.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.purchase_advances.maximum(:amount)
      end
      begin
        results = @company.purchase_advances.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.purchase_advances.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date)
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
	    columns = %w[voucher_number voucher_date to_account_id amount created_at created_at]
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