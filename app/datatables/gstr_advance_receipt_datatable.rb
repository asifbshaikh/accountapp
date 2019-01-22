class GstrAdvanceReceiptDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Context
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
  include GstrAdvanceReceiptsHelper
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
      :iTotalRecords => gstr_advance_receipts.total_count,
      :iTotalDisplayRecords => gstr_advance_receipts.total_count,
      :aaData => data
    }
  end

def data
      #if !params[:customer].blank?
        #gstr_advance_receipts.map do |gstr_advance_receipt|
          #[
            #link_to(gstr_advance_receipt.gstr_advance_receipt_number, gstr_advance_receipt_path(gstr_advance_receipt)),
            #h(gstr_advance_receipt.gstr_advance_receipt_date),
            #{}"#{gstr_advance_receipt.currency} #{number_with_precision gstr_advance_receipt.total_amount, :precision=>2}",
            #h(gstr_advance_receipt.get_status),
          #]
        #end
      #else
        data_arr=[]
        gstr_advance_receipts.each do |gstr_advance_receipt|
          row=[]
          content=''
            content += content_tag :div, :class=>'modal fade', :id=>"modal#{gstr_advance_receipt.id}" do
              @view.render(:partial=>"/gstr_advance_receipts/email_form.html.erb",:locals=> {:gstr_advance_receipt=>gstr_advance_receipt})
            end

          content += link_to(gstr_advance_receipt.voucher_number, gstr_advance_receipt_path(gstr_advance_receipt))
          row<<content
          row<< gstr_advance_receipt.customer_name
          row<< h(gstr_advance_receipt.voucher_date)
          row<<("#{gstr_advance_receipt.currency} #{format_amount(gstr_advance_receipt.amount)}")
          row<< h(gstr_advance_receipt.get_status)
          row<<twitter_dropdown(gstr_advance_receipt)
          data_arr<<row
        end
        data_arr
      end
    


    def twitter_dropdown(gstr_advance_receipt)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", gstr_advance_receipt_path(gstr_advance_receipt),  :class => "btn btn-white btn-sm dropdown-toggle"
        
          if !@user.auditor?
            if (gstr_advance_receipt.status.blank? || gstr_advance_receipt.status == 0)
              b.link_to "Edit", edit_gstr_advance_receipt_path(gstr_advance_receipt)
              b.link_to "Allocate", "/gstr_advance_receipts/allocate?id=#{gstr_advance_receipt.id}"
              b.link_to "Delete", gstr_advance_receipt, :method => "delete", :confirm =>"Are you sure?" 
              #b.link_to "Export to PDF", gstr_advance_receipt_path(gstr_advance_receipt, :format => "pdf"), :target => "_blank"
              #b.link_to "Allocate To Invoice", {:controller => :receipt_advance, :action => :allocate, :gstr_advance_receipt_id => gstr_advance_receipt.id}
              #b.link_to "Convert To Sales Order", {:action => :convert_to_so, :id => gstr_advance_receipt.id}
            end
            b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{gstr_advance_receipt.id}"
          end
        
        b.link_to "Export to PDF", gstr_advance_receipt_path(gstr_advance_receipt, :format => "pdf",:print=>"yes"), :target => "_blank"
        
          b.content_tag :li,"",:class => "divider"
          if !@user.auditor?
            b.link_to "Delete", gstr_advance_receipt, :method => "delete", :confirm =>"Are you sure?" unless !gstr_advance_receipt.status.blank?
          end
        end
      end
    





 def gstr_advance_receipts
   @gstr_advance_receipts ||= fetch_gstr_advance_receipts
      
    end


 def customers
      @customers ||= fetch_customer_gstr_advance_receipts
    end


def fetch_gstr_advance_receipts
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        #@customer_ids = Account.get_account_ids(@company,search_params)
        gstr_advance_receipts = @company.gstr_advance_receipts.where("gstr_advance_receipts like ? or gstr_advance_receipt_date like ? or status like ? or total_amount like ? or account_id in (?)", search_params, search_params, search_params, search_params, @customer_ids)

      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        gstr_advance_receipts =  search_gstr_advance_receipts
      else
     
        gstr_advance_receipts = @company.gstr_advance_receipts.by_deleted(false)#.by_date(@financial_year)
      end
      gstr_advance_receipts = gstr_advance_receipts.order("#{sort_column} #{sort_direction}")
      gstr_advance_receipts = gstr_advance_receipts.page(page).per(per_page)
      gstr_advance_receipts
    end



 def fetch_customer_gstr_advance_receipts
      if params[:sSearch].present?
        gstr_advance_receipts = @company.gstr_advance_receipts.where("(gstr_advance_receipt_number like :search or gstr_advance_receipt_date like :search or status like :search or total_amount like :search) and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        gstr_advance_receipts = @company.gstr_advance_receipts.where(:from_account_id=>params[:customer].to_i).by_company_id(@user.company_id).by_deleted(false)#.by_date(@financial_year)
      end
      gstr_advance_receipts = gstr_advance_receipts.order("#{sort_column} #{sort_direction}")
      gstr_advance_receipts = gstr_advance_receipts.page(page).per(per_page)
      gstr_advance_receipts
    end



    def search_gstr_advance_receipts
      results = Array.new

      date_range=params[:sSearch_2].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.gstr_advance_receipts.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.gstr_advance_receipts.maximum(:amount)
      end
      begin
        results = @company.gstr_advance_receipts.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.gstr_advance_receipts.by_deleted(false).by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1])
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
      columns = %w[id gstr_advance_receipt_date total_amount status ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end







  #private
   

end