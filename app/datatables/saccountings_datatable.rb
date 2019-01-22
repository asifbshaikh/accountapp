class SaccountingsDatatable
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
      :iTotalRecords => saccountings.count,
      :iTotalDisplayRecords => saccountings.total_count, 
      :aaData => data
    }
  end

  private

    def data
      saccountings.map do |saccounting|
        [
          link_to(saccounting.voucher_number, saccounting_path(saccounting)),
          h(saccounting.voucher_date),
          saccounting.to_account_name,
          content_tag(:span, saccounting.total_amount, :class => "pull-right"),
          h(saccounting.created_by_user),
          twitter_dropdown(saccounting)
        ]
      end
    end
    

    def twitter_dropdown(saccounting)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", saccounting_path(saccounting),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Edit", edit_saccounting_path(saccounting) unless saccounting.in_frozen_year?
        b.link_to "Export to PDF", saccounting_path(saccounting, :format => "pdf"), :target => "_blank"
        b.content_tag :li,"",:class => "divider" unless saccounting.in_frozen_year?
        b.link_to "Delete", saccounting, :method => "delete", :confirm =>"Are you sure?"  unless saccounting.in_frozen_year?
      end      
    end

    def saccountings
      @saccountings ||= fetch_saccountings
    end

    def fetch_saccountings
      if params[:sSearch].present?
        saccountings = @company.saccountings.where("voucher_number like :search or voucher_date like :search or total_amount like :search", :search => "%#{params[:sSearch]}%")
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? 
        saccountings = search_saccountings
      else
        saccountings = @company.saccountings.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      saccountings.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

   def search_saccountings
      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.saccountings.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.saccountings.maximum(:total_amount)
      end
      begin
        results = @company.saccountings.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.saccountings.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2])
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
      columns = %w[voucher_number voucher_date total_amount ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end