class GstrAdvancePaymentDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Context
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
  include GstrAdvancePaymentsHelper
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
      :iTotalRecords => gstr_advance_payments.total_count,
      :iTotalDisplayRecords => gstr_advance_payments.total_count,
      :aaData => data
    }
  end

  private

    def data
      # if params[:customer].present?
      #   gstr_advance_payments.map do |adv_payment|
      #     [
      #       link_to(adv_payment.voucher_number, adv_payment_path(adv_payment)),
      #       h(adv_payment.voucher_date),
      #       "#{adv_payment.currency} #{number_with_precision adv_payment.amount, :precision=>2}",
      #       h(adv_payment.get_status),
      #     ]
      #   end
      # else
        data_arr=[]
        gstr_advance_payments.each do |adv_payment|
          row=[]
          content=''
            content += content_tag :div, :class=>'modal fade', :id=>"modal#{adv_payment.id}" do
              #@view.render(:partial=>"/gstr_advance_payments/email_form.html.erb", :locals => {:gstr_advance_payment=>adv_payment})
            end
          content += link_to(adv_payment.voucher_number, gstr_advance_payment_path(adv_payment))
          row<<content
          row<< adv_payment.customer_name
          row<< h(adv_payment.voucher_date)
          row<<content_tag(:span, ("#{adv_payment.currency} #{format_amount(adv_payment.amount)}"), :class => "pull-right")
          row<< h(adv_payment.get_status)
          row<<twitter_dropdown(adv_payment)
          data_arr<<row
        end
        Rails.logger.debug "=====================after getting all rows==========================="
        data_arr
      # end
    end

     def twitter_dropdown(gstr_advance_payment)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", gstr_advance_payment_path(gstr_advance_payment),  :class => "btn btn-white btn-sm dropdown-toggle"
        if gstr_advance_payment.status.blank? || gstr_advance_payment.status==0
            b.link_to "Edit", edit_gstr_advance_payment_path(gstr_advance_payment)
            b.link_to "Allocate To Payment",  {:controller => :gstr_advance_payments, :action => :allocate, :id => gstr_advance_payment.id} if  !gstr_advance_payment.status? #{:controller => :gstr_advance_payments, :action => :allocate, :gstr_advance_payment_id => gstr_advance_payment.id}
            b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{gstr_advance_payment.id}"
            b.link_to "Delete", gstr_advance_payment, :method => "delete", :confirm =>"Are you sure?"
        end
        b.link_to "Export to PDF", gstr_advance_payment_path(gstr_advance_payment, :format => "pdf",:print=>"yes"), :target => "_blank"
        b.content_tag :li,"",:class => "divider"
        b.link_to "Delete", gstr_advance_payment, :method => "delete", :confirm =>"Are you sure?" unless !gstr_advance_payment.status.blank?
      end
    end


    def gstr_advance_payments
        if params[:customer].present?
          @gstr_advance_payments ||= fetch_customer_gstr_advance_payments
        elsif params[:project].present?
          @gstr_advance_payments ||= fetch_project_gstr_advance_payments
        elsif params[:gstr_advance_payment_status_id].present?
          @gstr_advance_payments ||= fetch_draft_gstr_advance_payments
        else
          @gstr_advance_payments ||= fetch_gstr_advance_payments
        end
    end

    def fetch_gstr_advance_payments
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        gstr_advance_payments = @company.gstr_advance_payments.where("voucher_number like ? or voucher_date like ? or status like ? or amount like ? or to_account_id in (?)", search_params, search_params, search_params, search_params, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        #gstr_advance_payments =  search_gstr_advance_payments
        # logger.debug "gstr_advance_payments=======#######=============================="
        # logger.debug gstr_advance_payments.inspect
      else
        Rails.logger.debug "==========================without search==========================="
        gstr_advance_payments = @company.gstr_advance_payments.by_deleted(false)#.by_date(@financial_year)
      end
      gstr_advance_payments = gstr_advance_payments.order("#{sort_column} #{sort_direction}")
      gstr_advance_payments = gstr_advance_payments.page(page).per(per_page)
      gstr_advance_payments
    end

    def fetch_customer_gstr_advance_payments
      if params[:sSearch].present?
        gstr_advance_payments = @company.gstr_advance_payments.where("(voucher_number like :search or voucher_date like :search or status like :search or total_amount like :search) and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        gstr_advance_payments = @company.gstr_advance_payments.where(:account_id=>params[:customer].to_i).by_company_id(@user.company_id).by_deleted(false)#.by_date(@financial_year)
      end
      gstr_advance_payments = gstr_advance_payments.order("#{sort_column} #{sort_direction}")
      gstr_advance_payments = gstr_advance_payments.page(page).per(per_page)
      gstr_advance_payments
    end

    def sort_column
      columns = %w[id voucher_date amount status ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

end