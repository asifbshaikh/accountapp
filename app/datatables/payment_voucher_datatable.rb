class PaymentVoucherDatatable
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
      :iTotalRecords => payment_vouchers.count,
      :iTotalDisplayRecords => payment_vouchers.total_count, 
      :aaData => data
    }
  end

  private
    def data
      if params[:vendor].present?
        payment_vouchers.map do |payment_voucher|
          [
            link_to(payment_voucher.voucher_number, payment_voucher_path(payment_voucher)),
            h(payment_voucher.payment_date),
            "#{payment_voucher.currency_code} #{format_amount(payment_voucher.amount)}",
            h(payment_voucher.payment_detail.payment_mode),
          ]
        end
      else
        payment_vouchers.map do |payment_voucher|
          [
            link_to(payment_voucher.voucher_number, payment_voucher_path(payment_voucher)),
            h(payment_voucher.payment_date),
            h(payment_voucher.to_account.name),
            "#{payment_voucher.currency_code} #{format_amount(payment_voucher.amount)}",
            h(payment_voucher.payment_detail.payment_mode),
            twitter_dropdown(payment_voucher)
          ]
        end
      end
    end

    def twitter_dropdown(payment_voucher)

      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white dropdown-toggle btn-sm"}) do |b|
          b.bootstrap_button "View", payment_voucher_path(payment_voucher),  :class => "btn btn-white  dropdown-toggle btn-sm"
          b.link_to "Allocate Amount", "/payment_vouchers/allocate?id=#{payment_voucher.id}" if payment_voucher.advance_payment? && !payment_voucher.allocated? 
          b.link_to "Edit", edit_payment_voucher_path(payment_voucher) #unless payment_voucher.in_frozen_year?
          b.link_to "Export to PDF", payment_voucher_path(payment_voucher, :format => "pdf"), :target=>"_blank"
          b.content_tag :li,"",:class => "divider" #unless payment_voucher.in_frozen_year?
          b.link_to "Delete", payment_voucher, :method => "delete", :confirm =>"Are you sure?"  #unless payment_voucher.in_frozen_year?
      end      
    end

    def voucher_detail(payment_voucher)
      content_tag :a, payment_voucher.voucher_number, :"data-toggle" =>"popover", :"data-html"=> "true", :"data-placement" =>"right",
       :"data-content" =>"Hi", :"data-original-title"=>'X'
    end

    def payment_vouchers
      if params[:vendor].present?
        @payment_vouchers ||= fetch_vendor_payment_vouchers
      elsif params[:voucher_type].present?
        @payment_vouchers ||= send("fetch_#{PaymentVoucher::PAYMENT_OPTION[params[:voucher_type].to_i]}")
      else
        @payment_vouchers ||= fetch_payment_vouchers
      end
    end

    def fetch_advance_payment
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @account_ids = Account.get_account_ids(@company,search_params)
        payment_vouchers = @company.payment_vouchers.by_voucher_type(1).joins(:payment_detail).where("payment_vouchers.voucher_number like ? or payment_vouchers.amount like ? or payment_vouchers.voucher_date like ? or payment_details.type like ? or payment_vouchers.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)        
      else
        payment_vouchers = @company.payment_vouchers.includes(:currency).includes(:payment_detail).
          includes(:to_account).includes(:from_account).by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(1)
      end
      payment_vouchers = payment_vouchers.order("#{sort_column} #{sort_direction}")
      payment_vouchers.page(page).per(per_page)
    end

    def fetch_other_payment
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @account_ids = Account.get_account_ids(@company, search_params)
        payment_vouchers = @company.payment_vouchers.by_voucher_type(2).joins(:payment_detail).where("payment_vouchers.voucher_number like ? or payment_vouchers.amount like ? or payment_vouchers.voucher_date like ? or payment_details.type like ? or payment_vouchers.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)        
      else
        payment_vouchers = @company.payment_vouchers.by_branch_id(@user.branch_id).by_deleted(false).by_voucher_type(2)
      end
      payment_vouchers = payment_vouchers.order("#{sort_column} #{sort_direction}")
      payment_vouchers.page(page).per(per_page)
    end

    def fetch_vendor_payment_vouchers
      if params[:sSearch].present?
        #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        payment_vouchers = @company.payment_vouchers.where("(voucher_number like :search or amount like :search) and to_account_id=#{params[:vendor].to_i}", :search => "%#{params[:sSearch]}%")
      elsif params[:sSearch_0].present? 
        payment_vouchers = search_payment_vouchers
      else
        payment_vouchers = @company.payment_vouchers.where(:to_account_id=>params[:vendor].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      payment_vouchers = payment_vouchers.order("#{sort_column} #{sort_direction}")
      payment_vouchers.page(page).per(per_page)
    end

    def fetch_payment_vouchers
      if params[:sSearch].present?
        #@company.customers.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        search_params = "%#{params[:sSearch]}%"
        @account_ids = Account.get_account_ids(@company,search_params)
        payment_vouchers = @company.payment_vouchers.by_voucher_type(0).joins(:payment_detail).where("payment_vouchers.voucher_number like ? or payment_vouchers.amount like ? or payment_vouchers.voucher_date like ? or payment_details.type like ? or payment_vouchers.to_account_id in (?)", search_params, search_params, search_params, search_params, @account_ids)
      elsif params[:sSearch_0].present?|| params[:sSearch_1].present? || params[:sSearch_2].present?||params[:sSearch_3].present?||params[:sSearch_4].present?
        payment_vouchers = search_payment_vouchers
      else
        payment_vouchers = @company.payment_vouchers.by_voucher_type(0).includes(:currency).includes(:payment_detail).
        includes(:to_account).includes(:from_account).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      payment_vouchers = payment_vouchers.order("#{sort_column} #{sort_direction}")
      payment_vouchers.page(page).per(per_page)
    end

    def search_payment_vouchers
      results = Array.new
      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.payment_vouchers.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.payment_vouchers.maximum(:amount)
      end
      begin
        results = @company.payment_vouchers.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.payment_vouchers.by_voucher_type(params[:voucher_type]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_2]).by_date_range(start_date, end_date)
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
      columns = %w[id payment_date to_account_id amount created_at created_at]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end