class ReceiptVoucherDatatable
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
      :iTotalRecords => receipt_vouchers.count,
      :iTotalDisplayRecords => receipt_vouchers.total_count,
      :aaData => data
    }
  end

  private
    def data
      if params[:customer].present?
        receipt_vouchers.map do |receipt_voucher|
          [
            link_to(receipt_voucher.voucher_number, receipt_voucher_path(receipt_voucher)),
            h(receipt_voucher.voucher_date),
            content_tag(:span, (format_amt_with_currency(receipt_voucher.currency_code, receipt_voucher.amount))),
            receipt_voucher.payment_detail.payment_mode
          ]
        end
      elsif params[:project].present?
           receipt_vouchers.map do |receipt_voucher|
          [
            link_to(receipt_voucher.voucher_number, receipt_voucher_path(receipt_voucher)),
            receipt_voucher.from_account_name,
            h(receipt_voucher.received_date),
            content_tag(:span, (format_amt_with_currency(receipt_voucher.currency_code, receipt_voucher.amount))),
            receipt_voucher.payment_detail.payment_mode
          ]
        end
      else
        data_arr=[]
        receipt_vouchers.each do |receipt_voucher|
        row=[]
        content=''
          content += content_tag :div, :class=>'modal fade', :id=>"modal#{receipt_voucher.id}" do
            @view.render(:partial=>"/receipt_vouchers/email_form.html.erb",:locals=> {:receipt_voucher=>receipt_voucher})
          end

        content += link_to(receipt_voucher.voucher_number, receipt_voucher_path(receipt_voucher))
        row<<content
        row<<h(receipt_voucher.received_date)
        row<<receipt_voucher.from_account_name
        row<<content_tag(:span, (format_amt_with_currency(receipt_voucher.currency_code, receipt_voucher.amount))) 
        # "#{receipt_voucher.currency_code} #{receipt_voucher.amount}"
        row<<receipt_voucher.payment_detail.payment_mode
        row<< (!receipt_voucher.project_id.blank? ? receipt_voucher.project_name : "Not available")
        if params[:advanced]=='true'
          row<< receipt_voucher.allocated_status
          row<< receipt_voucher.unallocated_amount
        end  
        row<<twitter_dropdown(receipt_voucher)
        data_arr<<row
        end
         data_arr
      end
    end

    def twitter_dropdown(receipt_voucher)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", receipt_voucher_path(receipt_voucher),  :class => "btn btn-white btn-sm dropdown-toggle"
		    b.link_to "Allocate", "/receipt_vouchers/allocate?id=#{receipt_voucher.id}" if receipt_voucher.advanced?
        b.link_to "Edit", edit_receipt_voucher_path(receipt_voucher) #unless receipt_voucher.in_frozen_year?
        b.link_to "Export to PDF", receipt_voucher_path(receipt_voucher, :format => "pdf"), :target => "_blank"
        b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{receipt_voucher.id}" #unless receipt_voucher.in_frozen_year?
        b.content_tag :li,"",:class => "divider" #unless receipt_voucher.in_frozen_year?
        b.link_to "Delete", receipt_voucher, :method => "delete", :confirm =>"Are you sure?"  #unless receipt_voucher.in_frozen_year?
      end
    end

    def receipt_vouchers
      if params[:customer].present?
        @receipt_vouchers ||= fetch_customer_receipt_vouchers
      elsif params[:project].present?
        @receipt_vouchers ||= fetch_project_vouchers
      else
        @receipt_vouchers ||= fetch_receipt_vouchers
      end
    end

    def fetch_receipt_vouchers
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @from_account_ids = Account.get_account_ids(@company, search_params)
        @project_ids = Project.get_project_ids(@company, search_params)
				#[OPTIMIZE] This needs to be moved into the model.
        receipt_vouchers=@company.receipt_vouchers.joins(:payment_detail).where("payment_details.type like ? or receipt_vouchers.voucher_number like ? or receipt_vouchers.voucher_date like ? or receipt_vouchers.amount like ? or receipt_vouchers.from_account_id in (?) or receipt_vouchers.project_id in (?)", search_params, search_params, search_params, search_params, @from_account_ids, @project_ids)
        receipt_vouchers=receipt_vouchers.where(:advanced=>true) if !params[:advanced].blank? && params[:advanced]=='true'
      elsif params[:sSearch_0].present? || (params[:sSearch_1].present? && params[:sSearch_1]!="undefined~undefined") ||
        params[:sSearch_2].present? || params[:sSearch_3].present? || (params[:sSearch_4].present? && params[:sSearch_4]!="undefined~undefined")
        receipt_vouchers =  search_receipt_vouchers
      else
        receipt_vouchers = @company.receipt_vouchers.includes(:payment_detail).by_branch_id(@user.branch_id).by_deleted(false).by_advance(params[:advanced])#.by_date(@financial_year)
      end
      receipt_vouchers = receipt_vouchers.order("#{sort_column} #{sort_direction}")
      receipt_vouchers = receipt_vouchers.page(page).per(per_page)
      receipt_vouchers
    end

    def fetch_customer_receipt_vouchers
      if params[:sSearch].present?
        receipt_vouchers = @company.receipt_vouchers.where("(voucher_number like :search or voucher_date like :search or amount like :search) and from_account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        receipt_vouchers = @company.receipt_vouchers.where(:from_account_id=>params[:customer].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      receipt_vouchers = receipt_vouchers.order("#{sort_column} #{sort_direction}")
      receipt_vouchers = receipt_vouchers.page(page).per(per_page)
      receipt_vouchers
    end


   def fetch_project_vouchers
      if params[:sSearch].present?
        receipt_vouchers = @company.receipt_vouchers.where("(voucher_number like :search or voucher_date like :search or amount like :search) and project_id=#{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
      else
        receipt_vouchers = @company.receipt_vouchers.by_project(params[:project]).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      receipt_vouchers = receipt_vouchers.order("#{sort_column} #{sort_direction}")
      receipt_vouchers = receipt_vouchers.page(page).per(per_page)
      receipt_vouchers
    end

    def search_receipt_vouchers
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.receipt_vouchers.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.receipt_vouchers.maximum(:amount)
      end
      begin
        results = @company.receipt_vouchers.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_2]).by_date_range(start_date, end_date).by_project(params[:sSearch_3]).by_amount_range(min_amt, max_amt).by_advance(params[:advanced])
      rescue ArgumentError => e
        Rails.logger.error e
        results = @company.receipt_vouchers.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_2]).by_date_range(start_date, end_date).by_project(params[:sSearch_3]).by_advance(params[:advanced])
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
      columns = %w[id received_date amount ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

    # def format_currency(amt)
    #   unit = @company.country.currency_code
    #   number_to_currency(amt, :unit => unit+" ", :precision=> 2)
    # end
end
