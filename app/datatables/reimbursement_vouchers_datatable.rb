class ReimbursementVouchersDatatable
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
      :iTotalRecords => reimbursement_vouchers.count,
      :iTotalDisplayRecords => reimbursement_vouchers.total_count,
      :aaData => data
    }
  end

  private

    def data
      reimbursement_vouchers.map do |reimbursement_voucher|
        [
          link_to(reimbursement_voucher.voucher_number, reimbursement_voucher_path(reimbursement_voucher)),
          h(reimbursement_voucher.voucher_date.strftime("%d-%m-%Y")),
          truncate(reimbursement_voucher.from_account_id.blank? ? "" : Account.find(reimbursement_voucher.from_account_id).name, :length =>20),
          content_tag(:span, format_amount(reimbursement_voucher.amount), :class => "pull-right"),
          twitter_dropdown(reimbursement_voucher)
        ]
      end
    end


    def twitter_dropdown(reimbursement_voucher)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", reimbursement_voucher_path(reimbursement_voucher),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Edit", edit_reimbursement_voucher_path(reimbursement_voucher) unless reimbursement_voucher.in_frozen_year?
        b.link_to "Delete", reimbursement_voucher, :method => "delete", :confirm =>"Are you sure?"  unless reimbursement_voucher.in_frozen_year?
      end
    end

    def reimbursement_vouchers
      @reimbursement_vouchers ||= fetch_reimbursement_vouchers
    end

    def fetch_reimbursement_vouchers
      if params[:sSearch].present?
        reimbursement_vouchers = @company.reimbursement_vouchers.where("voucher_number like :search or voucher_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        reimbursement_vouchers = search_reimbursement_vouchers
      else
        reimbursement_vouchers = @company.reimbursement_vouchers.by_branch_id(@user.branch_id).by_deleted(false)
      end
      reimbursement_vouchers.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end


    def search_reimbursement_vouchers
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.reimbursement_vouchers.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.reimbursement_vouchers.maximum(:amount)
      end
      begin
        results = @company.reimbursement_vouchers.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_customer(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.reimbursement_vouchers.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_customer(params[:sSearch_2])
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
      columns = %w[voucher_number voucher_date from_account_id amount]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
end
