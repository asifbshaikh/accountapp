class EstimateDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Context
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user, financial_year)
    @view=view
    @company=company
    @user=user
    @financial_year=financial_year
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => estimates.count,
      :iTotalDisplayRecords => estimates.total_count,
      :aaData => data
    }
  end

  private

    def data
      if !params[:customer].blank?
        estimates.map do |estimate|
          [
            link_to(estimate.estimate_number, estimate_path(estimate)),
            h(estimate.estimate_date),
            "#{estimate.currency} #{format_amount(estimate.total_amount)}",
            h(estimate.get_status),
          ]
        end
      else
        data_arr=[]
        estimates.each do |estimate|
          row=[]
          content=''
            content += content_tag :div, :class=>'modal fade', :id=>"modal#{estimate.id}" do
              @view.render(:partial=>"/estimates/email_form.html.erb",:locals=> {:estimate=>estimate})
            end

          content += link_to(estimate.estimate_number, estimate_path(estimate))
          row<<content
          row<< estimate.customer_name
          row<< h(estimate.estimate_date)
          row<<content_tag(:span, ("#{estimate.currency} #{format_amount(estimate.total_amount)}"), :class => "pull-right")
          row<< h(estimate.get_status)
          row<<twitter_dropdown(estimate)
          data_arr<<row
        end
        data_arr
      end
    end


    def twitter_dropdown(estimate)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", estimate_path(estimate),  :class => "btn btn-white btn-sm dropdown-toggle"
        unless estimate.in_frozen_year?
          if !@user.auditor?
            if estimate.status.blank?
              b.link_to "Edit", edit_estimate_path(estimate)
              b.link_to "Convert To Invoice", {:controller => :invoices, :action => :converted_from_estimate, :estimate_id => estimate.id}
              if !@company.plan.professional_plan?
                b.link_to "Convert To Sales Order", {:action => :convert_to_so, :id => estimate.id}
              end  
            end
            b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{estimate.id}"
          end
        end
        b.link_to "Export to PDF", estimate_path(estimate, :format => "pdf",:print=>"yes"), :target => "_blank"
        unless estimate.in_frozen_year?
          b.content_tag :li,"",:class => "divider"
          if !@user.auditor?
            b.link_to "Delete", estimate, :method => "delete", :confirm =>"Are you sure?" unless !estimate.status.blank?
          end
        end
      end
    end

    def estimates
      if params[:customer].blank?
        @estimates ||= fetch_estimates
      else
        @estimates ||= fetch_customer_estimates
      end
    end

    def fetch_estimates
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Account.get_account_ids(@company,search_params)
        estimates = @company.estimates.where("estimate_number like ? or estimate_date like ? or status like ? or total_amount like ? or account_id in (?)", search_params, search_params, search_params, search_params, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        estimates =  search_estimates
      else
        estimates = @company.estimates.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      estimates = estimates.order("#{sort_column} #{sort_direction}")
      estimates = estimates.page(page).per(per_page)
      estimates
    end

    def fetch_customer_estimates
      if params[:sSearch].present?
        estimates = @company.estimates.where("(estimate_number like :search or estimate_date like :search or status like :search or total_amount like :search) and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        estimates = @company.estimates.where(:account_id=>params[:customer].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      estimates = estimates.order("#{sort_column} #{sort_direction}")
      estimates = estimates.page(page).per(per_page)
      estimates
    end

    def search_estimates
      results = Array.new

      date_range=params[:sSearch_2].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.estimates.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.estimates.maximum(:total_amount)
      end
      begin
        results = @company.estimates.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.estimates.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4])
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
      columns = %w[id estimate_date total_amount status ]
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
