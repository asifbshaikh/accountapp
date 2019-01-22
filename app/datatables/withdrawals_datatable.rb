class WithdrawalsDatatable
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
      :iTotalRecords => withdrawals.count,
      :iTotalDisplayRecords => withdrawals.total_count,
      :aaData => data
    }
  end

  private

    def data
      withdrawals.map do |withdrawal|
        [
          withdrawal.voucher_number,
          h(withdrawal.transaction_date.strftime("%d-%m-%Y")),
          truncate(withdrawal.from_account_name, :length =>20),
          truncate(withdrawal.to_account_name, :length =>20),
          content_tag(:span, format_amount(withdrawal.amount), :class => "pull-right"),
          twitter_dropdown(withdrawal)
        ]
      end
    end

    def twitter_dropdown(withdrawal)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", withdrawal_path(withdrawal),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Edit", edit_withdrawal_path(withdrawal) unless withdrawal.in_frozen_year?
        b.link_to "Delete", withdrawal, :method => "delete", :confirm =>"Are you sure?" unless withdrawal.in_frozen_year?
      end
    end

    def withdrawals
      @withdrawals ||= fetch_withdrawals
    end

    def fetch_withdrawals
      if params[:sSearch].present?
        withdrawals = @company.withdrawals.where("voucher_number like :search or transaction_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        withdrawals = search_withdrawals
      else
        withdrawals = @company.withdrawals.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      withdrawals.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end


    def search_withdrawals
      results = Array.new
      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.withdrawals.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.withdrawals.maximum(:amount)
      end
      begin
        results = @company.withdrawals.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.withdrawals.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3])
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