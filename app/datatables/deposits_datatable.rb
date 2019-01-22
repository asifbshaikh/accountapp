class DepositsDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
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
      :iTotalRecords => deposits.count,
      :iTotalDisplayRecords => deposits.total_count,
      :aaData => data
    }
  end

  private

    def data
      deposits.map do |deposit|
        [
          deposit.voucher_number,
          h(deposit.transaction_date.strftime("%d-%m-%Y")),
          truncate(Account.find(deposit.from_account_id).name, :length =>20),
          truncate(Account.find(deposit.to_account_id).name, :length =>20),
          content_tag(:span, format_amount(deposit.amount), :class => "pull-right"),
          twitter_dropdown(deposit)
        ]
      end
    end

    def twitter_dropdown(deposit)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", deposit_path(deposit),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Edit", edit_deposit_path(deposit) unless deposit.in_frozen_year?
        b.link_to "Delete", deposit, :method => "delete", :confirm =>"Are you sure?"  unless deposit.in_frozen_year?
      end
    end

    def deposits
      @deposits ||= fetch_deposits
    end

    def fetch_deposits
      if params[:sSearch].present?
        deposits = @company.deposits.where("voucher_number like :search or transaction_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        deposits = search_deposits
      else
        deposits = @company.deposits.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      deposits.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def search_deposits
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.deposits.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.deposits.maximum(:amount)
      end
      begin
        results = @company.deposits.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.deposits.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3])
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
      columns = %w[voucher_number transaction_date amount  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end