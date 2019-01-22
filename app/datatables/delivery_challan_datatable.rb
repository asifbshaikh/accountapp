class DeliveryChallanDatatable
  include Rails.application.routes.url_helpers 
  include ActionView::Helpers
  include ActionView::Context
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
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
      :iTotalRecords => delivery_challans.count,
      :iTotalDisplayRecords => delivery_challans.total_count, 
      :aaData => data
    }
  end

  private

    def data
      if params[:sales_order].present?
        delivery_challans.map do |delivery_challan|
          [
            link_to(delivery_challan.voucher_number, delivery_challan_path(delivery_challan)),
            h(SalesOrder.find(delivery_challan.sales_order_id).voucher_number),
            delivery_challan.customer_name,
            h(delivery_challan.voucher_date),
            twitter_dropdown(delivery_challan)
          ]
        end
      else
        delivery_challans.map do |delivery_challan|
          [
            link_to(delivery_challan.voucher_number, delivery_challan_path(delivery_challan)),
            h(SalesOrder.find(delivery_challan.sales_order_id).voucher_number),
            delivery_challan.customer_name,
            h(delivery_challan.voucher_date),
            twitter_dropdown(delivery_challan)
          ]
        end
      end
    end
    

    def twitter_dropdown(delivery_challan)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View PDF", delivery_challan_path(delivery_challan, :format => "pdf"), :target => "_blank",  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "View", delivery_challan_path(delivery_challan)
        # b.content_tag :li,"",:class => "divider"
        # b.link_to "Delete", sales_order, :method => "delete", :confirm =>"Are you sure?" 
      end      
    end

    def delivery_challans
       if params[:sales_order].blank?
        @delivery_challans ||= fetch_delivery_challans
       else
         @delivery_challans ||= fetch_sales_order_delivery_challans
       end
    end

    def fetch_delivery_challans
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Account.get_account_ids(@company,search_params)
        delivery_challans = @company.delivery_challans.where("voucher_number like ? or voucher_date like ? or account_id in (?)", search_params, search_params, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? 
        delivery_challans =  search_delivery_challans
      else
        delivery_challans = @company.delivery_challans.by_date(@financial_year)
      end
      delivery_challans = delivery_challans.order("#{sort_column} #{sort_direction}")
      delivery_challans = delivery_challans.page(page).per(per_page)
      delivery_challans
    end


    def fetch_sales_order_delivery_challans
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Account.get_account_ids(@company,search_params)
        delivery_challans = @company.delivery_challans.where("voucher_number like ? or voucher_date like ? or account_id in (?)", search_params, search_params, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? 
        delivery_challans =  search_delivery_challans
      else
        delivery_challans = @company.delivery_challans.by_date(@financial_year).by_sales_order(params[:sales_order])
      end
      delivery_challans = delivery_challans.order("#{sort_column} #{sort_direction}")
      delivery_challans = delivery_challans.page(page).per(per_page)
      delivery_challans
    end
    def search_delivery_challans
      results = Array.new

      if !params[:sSearch_2].blank?
        date_range=params[:sSearch_2].split("~")
        start_date= date_range[0].blank? ? @financial_year.start_date : date_range[0].to_date
        end_date= date_range[1].blank? ? @financial_year.end_date : date_range[1].to_date
      else
        start_date=@financial_year.start_date
        end_date=@financial_year.end_date
      end

      begin
        results = @company.delivery_challans.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_sales_order_id(params[:sSearch_3])
      rescue ArgumentError => e
        results = @company.delivery_challans.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_sales_order_id(params[:sSearch_3])
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
      columns = %w[voucher_number voucher_date sales_order_id account_id ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
    
end