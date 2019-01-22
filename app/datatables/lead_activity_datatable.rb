class LeadActivityDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view)
    @view =view
    @company = company
    @user = user
    @financial_year = financial_year
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => activity_reports.count,
      :iTotalDisplayRecords => activity_reports.total_count,
      :aaData => data
    }
  end

  private
    def data
        activity_reports.map do |activity|
          [
            link_to(invoice.invoice_number, invoice_path(invoice)),
            link_to(invoice.customer_name, account_path(invoice.account_id)),
            h(invoice.due_date),
            content_tag(:span, format_currency(invoice.amount), :class => "pull-right"),
            h(invoice.get_status),
            h(invoice.project_name),
            twitter_dropdown(invoice)
          ]
        end

    end

    def twitter_dropdown(invoice)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", invoice_path(invoice),  :class => "btn btn-white btn-sm dropdown-toggle"
        if invoice.cash_invoice?
          b.link_to "Edit", edit_invoice_path(invoice)
          b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id, :cash_invoice => true}
        elsif invoice.time_invoice?
          b.link_to "Edit", edit_invoice_path(invoice, :time_invoice => true)
          b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id, :time_invoice => true}
        else
          b.link_to "Edit", edit_invoice_path(invoice)
          b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id}
        end

        b.link_to "Export to PDF", invoice_path(invoice, :format => "pdf", :dlc=>"no"), :target => "_blank"
        if !invoice.time_invoice? && @company.plan.smb_plan?
          b.link_to "Print Delivery Challan", invoice_path(invoice, :format => "pdf", :dlc=>"yes"), :target => "_blank"
        end
        b.content_tag :li,"",:class => "divider"
        b.link_to "Delete", invoice, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def invoices
      if params[:customer].present?
        @invoices ||= fetch_customer_invoices
      else
        @invoices ||= fetch_invoices
      end
    end

    def fetch_invoices
      if params[:sSearch].present?
        invoices = @company.invoices.where("invoice_number like :search or total_amount like :search or due_date like :search", :search => "%#{params[:sSearch]}%")
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        invoices =  search_invoices
      else
        invoices = @company.invoices.by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year)
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per(per_page)
    end

    def fetch_customer_invoices
      if params[:sSearch].present?
        invoices = @company.invoices.where("(invoice_number like :search or total_amount like :search or due_date like :search and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        invoices = @company.invoices.by_customer(params[:customer]).by_branch_id(@user.branch_id).by_deleted(false).by_date(@financial_year)
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per(per_page)
    end

    def search_invoices
      results = Array.new

      if !params[:sSearch_2].blank?
        date_range=params[:sSearch_2].split("~")
        start_date= date_range[0].blank? ? @financial_year.start_date : date_range[0].to_date
        end_date= date_range[1].blank? ? @financial_year.end_date : date_range[1].to_date
      else
        start_date=@financial_year.start_date
        end_date=@financial_year.end_date
      end

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.invoices.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.invoices.maximum(:total_amount)
      end
      results = @company.invoices.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_project(params[:sSearch_5]).by_amount_range(min_amt, max_amt)
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[invoice_number due_date total_amount status project]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
    def format_currency(amt)
      unit = @company.country.currency_code
      number_to_currency(amt, :unit => unit+" ", :precision=> 2)
    end

end