class SalesOrderDatatable
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
      :iTotalRecords => sales_orders.count,
      :iTotalDisplayRecords => sales_orders.total_count, 
      :aaData => data
    }
  end

  private

    def data
      if params[:customer].present?
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, sales_order_path(sales_order)),
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.get_status.truncate(15)),
            h(sales_order.get_billing_status.truncate(15)),
          ]
        end
      elsif params[:project].present?
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, sales_order_path(sales_order)),
            sales_order.customer_name,
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.created_by_user),
          ]
        end
      elsif params[:executed].present?
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, sales_order_path(sales_order)),
            sales_order.customer_name,
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.get_status.truncate(15)),
            h(sales_order.get_billing_status.truncate(15)),
            twitter_dropdown(sales_order)
          ]
        end
      elsif params[:draft].present?
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, edit_sales_order_path(sales_order)),
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.get_status.truncate(15)),
            h(sales_order.get_billing_status.truncate(15)),
            draft_twitter_dropdown(sales_order)
          ]
        end
      elsif params[:cancelled].present?
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, sales_order_path(sales_order)),
            sales_order.customer_name,
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.get_status.truncate(15)),
            h(sales_order.get_billing_status.truncate(15)),
            twitter_dropdown(sales_order)
          ]
        end
      else
        sales_orders.map do |sales_order|
          [
            link_to(sales_order.voucher_number, sales_order_path(sales_order)),
            sales_order.customer_name,
            h(sales_order.voucher_date),
            "#{sales_order.currency} #{format_amount(sales_order.total_amount)}",
            h(sales_order.get_status.truncate(15)),
            h(sales_order.get_billing_status.truncate(15)),
            twitter_dropdown(sales_order)
          ]
        end
      end
    end
    
    def draft_twitter_dropdown(sales_order)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "Edit", edit_sales_order_path(sales_order),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Delete", sales_order, :method => "delete", :confirm =>"Are you sure?"
      end      
    end

    def twitter_dropdown(sales_order)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", sales_order_path(sales_order),  :class => "btn btn-white btn-sm dropdown-toggle"
         if sales_order.status == 1 || sales_order.status == 2
         b.link_to "Create Delivery Challan", new_delivery_challan_path(:sales_order_id=> sales_order.id)
         end
         b.link_to "Export to PDF", sales_order_path(sales_order, :format => "pdf"), :target => "_blank"
        if !@user.inventory_manager?
         if (sales_order.status == 2 || sales_order.status == 3) && (sales_order.billing_status == 0 || sales_order.billing_status == 1) &&
             (sales_order.total_delivered_qty != sales_order.total_invoiced_qty)
         b.link_to "Create Invoice", "/invoices/created_from_sales_order?sales_order_id=#{sales_order.id}&so_invoice=1"
         end
         b.content_tag :li,"",:class => "divider"
         if sales_order.status == 1
         b.link_to "Edit", edit_sales_order_path(sales_order) 
         b.link_to "Cancel Sales Order", "/sales_orders/cancel_order?id=#{sales_order.id}"
         end
         if sales_order.status == 1 || sales_order.status == 5
         b.link_to "Delete", sales_order, :method => "delete", :confirm =>"Are you sure?"
         end 
       end
      end      
    end

    def sales_orders
      if params[:customer].present?
        @sales_orders ||= fetch_customer_sales_orders
      elsif params[:project]
        @sales_orders ||= fetch_project_sales_orders
      elsif params[:executed].present?
        @sales_orders ||= fetch_executed_sales_orders
      elsif params[:draft].present?
        @sales_orders ||= fetch_draft_sales_orders
      elsif params[:cancelled].present?
        @sales_orders ||= fetch_cancelled_sales_orders
      else
        @sales_orders ||= fetch_sales_orders
      end
    end

    def fetch_sales_orders
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Customer.get_ids(@company,search_params)
        @status = SalesOrder.get_status_id(search_params)
        @billing_status = SalesOrder.get_billing_status(search_params)
        sales_orders = @company.sales_orders.by_status([1,2]).by_branch_id(@user.branch_id).where("voucher_number like ? or voucher_date like ? or total_amount like ? or status like ? or billing_status like ? or customer_id in (?)", search_params, search_params, search_params, @status,@billing_status, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        sales_orders =  search_sales_orders
      else
        sales_orders = @company.sales_orders.by_status([1,2]).by_branch_id(@user.branch_id)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end
    def fetch_executed_sales_orders
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Customer.get_ids(@company,search_params)
        @status = SalesOrder.get_status_id(search_params)
        @billing_status = SalesOrder.get_billing_status(search_params)
        sales_orders = @company.sales_orders.by_status(3).by_branch_id(@user.branch_id).where("voucher_number like ? or voucher_date like ? or total_amount like ? or status like ? or billing_status like ? or account_id in (?)", search_params, search_params, search_params, @status,@billing_status, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        sales_orders =  search_sales_orders
      else
        sales_orders = @company.sales_orders.by_status(3).by_branch_id(@user.branch_id).this_year_and_previous_unbilled(@financial_year.start_date, @financial_year.end_date)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end
    def fetch_draft_sales_orders
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Customer.get_ids(@company,search_params)
        @status = SalesOrder.get_status_id(search_params)
        @billing_status = SalesOrder.get_billing_status(search_params)
        sales_orders = @company.sales_orders.by_status(4).by_branch_id(@user.branch_id).where("voucher_number like ? or voucher_date like ? or total_amount like ? or status like ? or billing_status like ? or account_id in (?)", search_params, search_params, search_params, @status,@billing_status, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        sales_orders =  search_sales_orders
      else
        sales_orders = @company.sales_orders.by_status(4).by_branch_id(@user.branch_id)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end
    def fetch_cancelled_sales_orders
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @customer_ids = Customer.get_ids(@company,search_params)
        @status = SalesOrder.get_status_id(search_params)
        @billing_status = SalesOrder.get_billing_status(search_params)
        sales_orders = @company.sales_orders.by_status(5).by_branch_id(@user.branch_id).where("voucher_number like ? or voucher_date like ? or total_amount like ? or status like ? or billing_status like ? or account_id in (?)", search_params, search_params, search_params, @status,@billing_status, @customer_ids)
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
        sales_orders =  search_sales_orders
      else
        sales_orders = @company.sales_orders.by_status(5).by_branch_id(@user.branch_id)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end
    
    def fetch_customer_sales_orders
      if params[:sSearch].present?
        sales_orders = @company.sales_orders.where("(voucher_number like :search or voucher_date like :search or status like :search or total_amount like :search) and account_id=#{params[:customer].to_i}", :search => "%#{params[:sSearch]}%")
      else
        sales_orders = @company.sales_orders.where(:account_id=>params[:customer].to_i).by_status([1,2])#.by_date(@financial_year)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end

    def fetch_project_sales_orders
      if params[:sSearch].present?
        sales_orders = @company.sales_orders.where("(voucher_number like :search or voucher_date like :search or status like :search or total_amount like :search) and project_id=#{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
      else
        sales_orders = @company.sales_orders.by_project(params[:project]).by_status([1,2])#.by_date(@financial_year)
      end
      sales_orders = sales_orders.order("#{sort_column} #{sort_direction}")
      sales_orders = sales_orders.page(page).per(per_page)
      sales_orders
    end

    def search_sales_orders
      results = Array.new
      # if !params[:sSearch_2].blank?
      #   date_range=params[:sSearch_2].split("~")
      #   start_date= date_range[0].blank? ? @financial_year.start_date : date_range[0].to_date
      #   end_date= date_range[1].blank? ? @financial_year.end_date : date_range[1].to_date
      # else
      #   start_date=@financial_year.start_date
      #   end_date=@financial_year.end_date
      # end
      date_range=params[:sSearch_2].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt=amount_range[0].blank? ? 0 : amount_range[0]
        max_amt=amount_range[1].blank? ? (@company.sales_orders.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.sales_orders.maximum(:total_amount)
      end
      begin
        results = @company.sales_orders.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_billing_status(params[:sSearch_5]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.sales_orders.by_voucher(params[:sSearch_0]).by_customer(params[:sSearch_1]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_billing_status(params[:sSearch_5])
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
      columns = %w[voucher_number voucher_date total_amount status billing_status]
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