class ReceiptAdvanceDatatable
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
	    :iTotalRecords => receipt_advances.count,
	    :iTotalDisplayRecords => receipt_advances.total_count, 
	    :aaData => data
	  }
	end

	private
	  def data
	  	if params[:vendor].present?
				receipt_advances.map do |receipt_advance|
		      [
		        link_to(receipt_advance.voucher_number, receipt_advance_path(receipt_advance)),
		        h(receipt_advance.payment_date),
		        "#{receipt_advance.currency} #{number_with_precision receipt_advance.amount, :precision=>2}",
		        h(receipt_advance.payment_detail.payment_mode),
		      ]
		    end
	  	else
		    receipt_advances.map do |receipt_advance|
		      [
		        link_to(receipt_advance.voucher_number, receipt_advance_path(receipt_advance)),
		        h(receipt_advance.payment_date),
		        h(receipt_advance.to_account_name),
		        "#{receipt_advance.currency} #{number_with_precision receipt_advance.amount, :precision=>2}",
		        h(receipt_advance.payment_detail.payment_mode),
		        twitter_dropdown(receipt_advance)
		      ]
		    end
		  end
	  end

	  def twitter_dropdown(receipt_advance)

	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white dropdown-toggle btn-sm"}) do |b|
	        b.bootstrap_button "View", receipt_advance_path(receipt_advance),  :class => "btn btn-white  dropdown-toggle btn-sm"
	        #b.link_to "Allocate Amount", "/receipt_advances/allocate?id=#{receipt_advance.id}" if receipt_advance.advance_payment? && !receipt_advance.allocated? 
	        b.link_to "Edit", edit_receipt_advance_path(receipt_advance) unless receipt_advance.in_frozen_year?
	        b.link_to "Export to PDF", receipt_advance_path(receipt_advance, :format => "pdf"), :target=>"_blank"
	        b.content_tag :li,"",:class => "divider" unless receipt_advance.in_frozen_year?
	        b.link_to "Delete", receipt_advance, :method => "delete", :confirm =>"Are you sure?"  unless receipt_advance.in_frozen_year?
	    end      
	  end

	  def voucher_detail(receipt_advance)
	  	content_tag :a, receipt_advance.voucher_number, :"data-toggle" =>"popover", :"data-html"=> "true", :"data-placement" =>"right",
	  	 :"data-content" =>"Hi", :"data-original-title"=>'X'
	  end

	  def receipt_advances
	  	if params[:vendor].present?
	    	@receipt_advances ||= fetch_vendor_receipt_advances
	    elsif params[:voucher_type].present?
	    	@receipt_advances ||= send("fetch_#{PaymentVoucher::PAYMENT_OPTION[params[:voucher_type].to_i]}")
	    else
	    	@receipt_advances ||= fetch_receipt_advances
	    end
	  end

	  def fetch_advance_payment
	  	if params[:sSearch].present?
				search_params = "%#{params[:sSearch]}%"
				@account_ids = Account.get_account_ids(@company,search_params)
				receipt_advances = @company.receipt_advances.by_voucher_type(1).joins(:payment_detail).where("receipt_advances.voucher_number like ? or receipt_advances.amount like ? or receipt_advances.voucher_date like ? or payment_details.type like ? or receipt_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)	  		
	  	else
		  	receipt_advances = @company.receipt_advances.by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(1)
		  end
		  receipt_advances = receipt_advances.order("#{sort_column} #{sort_direction}")
	  	receipt_advances.page(page).per(per_page)
	  end

	  def fetch_other_payment
	  	if params[:sSearch].present?
				search_params = "%#{params[:sSearch]}%"
				@account_ids = Account.get_account_ids(@company,search_params)
				receipt_advances = @company.receipt_advances.by_voucher_type(2).joins(:payment_detail).where("receipt_advances.voucher_number like ? or receipt_advances.amount like ? or receipt_advances.voucher_date like ? or payment_details.type like ? or receipt_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)	  		
	  	else
		  	receipt_advances = @company.receipt_advances.by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(2)
		  end
		  receipt_advances = receipt_advances.order("#{sort_column} #{sort_direction}")
	  	receipt_advances.page(page).per(per_page)
	  end

	  def fetch_vendor_receipt_advances
	  	if params[:sSearch].present?
	  	  #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	  	  receipt_advances = @company.receipt_advances.where("(voucher_number like :search or amount like :search) and to_account_id=#{params[:vendor].to_i}", :search => "%#{params[:sSearch]}%")
	  	elsif params[:sSearch_0].present? 
	  	  receipt_advances = search_receipt_advances
	  	else
	  	  receipt_advances = @company.receipt_advances.where(:to_account_id=>params[:vendor].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	  	end
	  	receipt_advances = receipt_advances.order("#{sort_column} #{sort_direction}")
	  	receipt_advances.page(page).per(per_page)
	  end
	  def fetch_receipt_advances
	    if params[:sSearch].present?
	      #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
	      search_params = "%#{params[:sSearch]}%"
	      @account_ids = Account.get_account_ids(@company,search_params)
	      receipt_advances = @company.receipt_advances.by_voucher_type(0).joins(:payment_detail).where("receipt_advances.voucher_number like ? or receipt_advances.amount like ? or receipt_advances.voucher_date like ? or payment_details.type like ? or receipt_advances.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)
	    elsif params[:sSearch_0].present?|| params[:sSearch_1].present? || params[:sSearch_2].present?||params[:sSearch_3].present?||params[:sSearch_4].present?
	      receipt_advances = search_receipt_advances
	    else
	      receipt_advances = @company.receipt_advances.by_voucher_type(0).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	    end
	    receipt_advances = receipt_advances.order("#{sort_column} #{sort_direction}")
	    receipt_advances.page(page).per(per_page)
	  end

	  def search_receipt_advances
      results = Array.new
      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.receipt_advances.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.receipt_advances.maximum(:amount)
      end
      begin
        results = @company.receipt_advances.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.receipt_advances.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date)
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
	    columns = %w[voucher_number payment_date to_account_id amount created_at created_at]
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