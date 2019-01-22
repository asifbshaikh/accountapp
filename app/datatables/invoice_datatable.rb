class InvoiceDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Context
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
  include InvoicesHelper
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
      :iTotalRecords => invoices.total_count,
      :iTotalDisplayRecords => invoices.total_count,
      :aaData => data
    }
  end

  private
    def data
      if params[:customer].present?
        invoices.map do |invoice|
          [
            h(invoice.invoice_date),
            link_to(invoice.invoice_number, invoice_path(invoice)),
            h(invoice.due_date),
            format_amt_with_currency(invoice.currency, invoice.total_amount),
            content_tag(:span, invoice.get_status, :class => "label  #{invoice_status_badge invoice.get_status}")
          ]
        end
      elsif params[:project].present?
        invoices.map do |invoice|
          [
            h(invoice.invoice_date),
            link_to(invoice.invoice_number, invoice_path(invoice)),
            invoice.customer_name,
            h(invoice.due_date),
            format_amt_with_currency(invoice.currency, (invoice.total_amount-invoice.total_returned)),
            h(invoice.created_by_user)
          ]
        end
      elsif params[:invoice_status_id].present?
        invoices.map do |invoice|
          [
            h(invoice.invoice_date),
            link_to(invoice.invoice_number, invoice.so_invoice? ? "invoices/created_from_sales_order?id=#{invoice.id}" : edit_invoice_path(invoice)),
            invoice.customer_name,
            h(invoice.due_date),
            content_tag(:span, (format_amt_with_currency(invoice.currency, invoice.total_amount)), :class => "pull-right"),
            content_tag(:span, invoice.get_status, :class => "label #{invoice_status_badge invoice.get_status}"),
            # h(invoice.project_name), commented because project column removed from datatable
            twitter_dropdown(invoice)
          ]
        end
      else
        data_arr=[]
        Rails.logger.debug "before starting invoices loop------------------"
        invoices.each do |invoice|
          row=[]
          content=''
          content += content_tag :div, :class=>'modal fade', :id=>"modal#{invoice.id}" do
            @view.render(:partial=>"/invoices/email_form.html.erb", :locals => {:invoice => invoice})
          end

          content += h(invoice.invoice_date) 
          row<<content
          row << link_to(invoice.invoice_number, invoice_path(invoice))
          row<< customer_name(invoice)
          row<< h(invoice.due_date)
          row<<content_tag(:span, (format_amt_with_currency(invoice.currency, invoice.total_amount)), :class => "pull-right")
          row<< content_tag(:span, invoice.get_status, :class => "label #{invoice_status_badge invoice.get_status}")

          row<<twitter_dropdown(invoice)
          data_arr<<row
        end
        data_arr
      end
    end

    def customer_name(invoice)
      if invoice.customer.present?
        link_to(invoice.customer.name, customer_path(invoice.customer))
      elsif invoice.cash_invoice?
        invoice.customer_name
      else
        customer = invoice.account.customer.present? ? invoice.account.customer : invoice.account.vendor  
        customer.name
      end
    end

    def twitter_dropdown(invoice)
      send("#{Invoice::INVOICE_TYPE[invoice.draft?]}_invoice_actions", invoice)
    end

    def draft_invoice_actions(invoice)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        if invoice.so_invoice?
          b.bootstrap_button "Edit", "invoices/created_from_sales_order?id=#{invoice.id}",  :class => "btn btn-white btn-sm dropdown-toggle"
        else
          b.bootstrap_button "Edit", edit_invoice_path(invoice),  :class => "btn btn-white btn-sm dropdown-toggle"
        end
        b.link_to "Delete", invoice, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def discharge_invoice_actions(invoice)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", invoice_path(invoice),  :class => "btn btn-white btn-sm dropdown-toggle"
        send("#{FinancialYear::STATUS[invoice.in_frozen_year?]}_invoice_actions", invoice, b)
      end
    end

    def frozen_invoice_actions(invoice, b)
      b.link_to "Export to PDF", invoice_path(invoice, :format => "pdf", :dlc=>"no"), :target => "_blank"
    end

    def unfreeze_invoice_actions(invoice, b)
      if !@user.auditor?
        send("#{Invoice::RETURN_STATUS[invoice.has_return_any?]}_invoice_actions", invoice, b)
        b.link_to "Email Invoice", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{invoice.id}"
      end
      b.link_to "Export to PDF", invoice_path(invoice, :format => "pdf", :value=>"1", :dlc=>"no"), :target => "_blank"
    end

    def returned_invoice_actions(invoice, b)
      b.link_to raw('Return This Invoice'), new_invoice_return_path(:invoice_id => invoice.id)
    end

    def non_returned_invoice_actions(invoice, b)
      send("#{invoice.invoice_type}_actions", invoice, b)
    end

    def cash_invoice_actions(invoice, b)
      b.link_to "Edit", edit_invoice_path(invoice) unless invoice.settled?
      b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id, :cash_invoice => true}
    end

    def time_invoice_actions(invoice, b)
      b.link_to "Edit", edit_invoice_path(invoice, :time_invoice => true) unless invoice.settled?
      b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id, :time_invoice => true} unless invoice.recursive_invoice?
    end

    def so_invoice_actions(invoice, b)
      b.link_to "Return this Invoice", new_invoice_return_path(:invoice_id=>invoice.id) unless invoice.fully_returned?
    end

    def credit_invoice_actions(invoice, b)
      b.link_to "Edit", edit_invoice_path(invoice) unless invoice.settled?
      b.link_to "Copy to New", {:controller => :invoices, :action => :copy_invoice, :id => invoice.id}
      b.link_to "Return this Invoice", new_invoice_return_path(:invoice_id=>invoice.id) unless invoice.fully_returned?
    end

    def invoices
      if params[:customer].present?
        @invoices ||= fetch_customer_invoices
      elsif params[:project].present?
        @invoices ||= fetch_project_invoices
      elsif params[:invoice_status_id].present?
        @invoices ||= fetch_draft_invoices
      else
        @invoices ||= fetch_invoices
      end
    end

    def fetch_draft_invoices
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Account.get_account_ids(@company,search_params)
        @project_ids = Project.get_project_ids(@company,search_params)
        invoices = @company.invoices.where("invoice_number like ? or total_amount like ? or invoice_date like ? or due_date like ? or cash_customer_name like ? or account_id in (?) or project_id in (?)", search_params,search_params,search_params, search_params, search_params, @customer_ids, @project_ids).by_status(1)
      else
        invoices = @company.invoices.by_branch_id(@user.branch_id).by_deleted(false).by_status(1)
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per(per_page)
    end

    def fetch_invoices
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Account.get_account_ids(@company,search_params)
        @project_ids = Project.get_project_ids(@company,search_params)
        @status_ids = Invoice.get_status_id(search_params)
        invoices = @company.invoices.where("invoice_number like ? or total_amount like ? or invoice_date like ? or due_date like ? or cash_customer_name like ? or account_id in (?) or invoice_status_id = ? or project_id in (?)", search_params,search_params,search_params, search_params, search_params, @customer_ids, @status_ids, @project_ids)
      elsif search_params_present?
        invoices =  search_invoices
      else
        # start_date=@financial_year.get_first_date
        invoices = @company.invoices.includes(:account).includes(:customer).by_branch_id(@user.branch_id).by_deleted(false) #.order("invoice_date DESC")
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def fetch_customer_invoices
      if params[:sSearch].present?
        invoices = @company.invoices.where("(invoice_number like :search or total_amount like :search or invoice_date like :search or due_date like :search) and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        invoices = @company.invoices.by_customer(params[:customer]).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per(per_page)
    end

    def fetch_project_invoices
      if params[:sSearch].present?
        invoices = @company.invoices.where("(invoice_number like :search or total_amount like :search or due_date like :search or invoice_date like :search) and project_id=#{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
      else
        invoices = @company.invoices.by_project(params[:project]).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      invoices = invoices.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per(per_page)
    end

    def search_invoices
      results = Array.new

      invoice_date_range=params[:sSearch_2].split("~")
      invoice_start_date = DataValidate.parsed_start_date(@financial_year, invoice_date_range[0])
      invoice_end_date = DataValidate.parsed_end_date(@financial_year, invoice_date_range[1])

      date_range=params[:sSearch_3].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if params[:sSearch_4]!="~"
        amount_range=params[:sSearch_4].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.invoices.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.invoices.maximum(:total_amount)
      end
      begin
        results = @company.invoices.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_invoice_date_range(invoice_start_date, invoice_end_date).by_status(params[:sSearch_2]).by_date_range(start_date, end_date).by_status(params[:sSearch_5]).by_project(params[:sSearch_6]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.invoices.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_invoice_date_range(invoice_start_date, invoice_end_date).by_status(params[:sSearch_2]).by_date_range(start_date, end_date).by_status(params[:sSearch_5]).by_project(params[:sSearch_6])
      end


      results
    end

    def search_params_present?
      search_keys = [:sSearch_0, :sSearch_1, :sSearch_2, :sSearch_3, :sSearch_4, :sSearch_5, :sSearch_6]
      search_keys.each do |key|
        if params[key].present? && params[key] != "~"
          return true
        end
      end
      false
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 25
    end

    def sort_column
      columns = %w[invoice_date id account_id due_date total_amount invoice_status_id project_id]
      sort_col_index = params[:iSortCol_0].to_i
      #FIX for invlaid sort column when the action column is clicked by user.
      # This fix can be removed when we figure out how to disable sorting for a
      # column in datatable
      if sort_col_index >= columns.size
        sort_col_index=0
      end
      columns[sort_col_index]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end
