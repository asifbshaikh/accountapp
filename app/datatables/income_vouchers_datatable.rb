class IncomeVouchersDatatable
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
      :iTotalRecords => income_vouchers.count,
      :iTotalDisplayRecords => income_vouchers.total_count, 
      :aaData => data
    }
  end

  private

    def data
      income_vouchers.map do |income_voucher|
        [
          income_voucher.voucher_number,
          income_voucher.income_date.strftime("%d-%m-%Y"),
          truncate(Account.find(income_voucher.from_account_id).name, :length =>20),
          content_tag(:span, income_voucher.amount, :class => "pull-right"),
          income_voucher.payment_detail.payment_mode ,
          twitter_dropdown(income_voucher)
          ]
      end
    end
    

    def twitter_dropdown(income_voucher)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "View", income_voucher_path(income_voucher),  :class => "btn btn-white btn-sm dropdown-toggle"
          b.link_to "Edit", edit_income_voucher_path(income_voucher) unless income_voucher.in_frozen_year?
          b.link_to "Export to PDF", income_voucher_path(income_voucher, :format => "pdf"), :target => "_blank"
          b.content_tag :li,"",:class => "divider" unless income_voucher.in_frozen_year?
          b.link_to "Delete", income_voucher, :method => "delete", :confirm =>"Are you sure?"  unless income_voucher.in_frozen_year?

      end      
    end

    def income_vouchers
      @income_vouchers ||= fetch_income_vouchers
    end

    def fetch_income_vouchers
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @from_account_ids = Account.get_account_ids(@company,search_params)
        income_vouchers = @company.income_vouchers.joins(:payment_detail).where("payment_details.type like ? or income_vouchers.voucher_number like ? or income_vouchers.income_date like ? or income_vouchers.amount like ? or income_vouchers.from_account_id in (?)",search_params, search_params, search_params, search_params, @from_account_ids )
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present?
        income_vouchers =  search_income_vouchers
      else
        income_vouchers = @company.income_vouchers.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      income_vouchers = income_vouchers.order("#{sort_column} #{sort_direction}")
      income_vouchers = income_vouchers.page(page).per(per_page)
      income_vouchers
    end

   def search_income_vouchers
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.income_vouchers.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.amount_vouchers.maximum(:amount)
      end
      begin
        results = @company.income_vouchers.by_deleted(:false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_2]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.income_vouchers.by_deleted(:false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_2]).by_date_range(start_date, end_date)
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
      columns = %w[voucher_number income_date amount  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end