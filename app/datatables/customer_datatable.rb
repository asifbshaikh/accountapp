class CustomerDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company)
    @view =view
    @company = company
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => customers.count,
      :iTotalDisplayRecords => customers.total_count,
      :aaData => data
    }
  end

  private
    def data
      customers.map do |customer|
        [
          link_to(customer.name, customer_path(customer)),
          format_currency(customer.credit_limit),
          h(customer.email),
          h(customer.primary_phone_number),
          twitter_dropdown(customer)
        ]
      end
    end

    def twitter_dropdown(customer)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
          b.bootstrap_button "View", customer_path(customer),  :class => "btn btn-white  dropdown-toggle btn-sm"
          # b.link_to "Edit", edit_customer_path(customer)
          b.content_tag :li,"",:class => "divider"
          b.link_to "Delete", customer, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def customers
      @customers ||= fetch_customers
    end

    def fetch_customers

      if params[:sSearch].present?
        #@company.customers.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(current_financial_year).search(params[:search])
        customers = @company.customers.where("name like :search or email like :search or primary_phone_number like :search or credit_limit like :search", :search => "%#{params[:sSearch]}%")
      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present?
        customers = search_customers
      else
        customers = @company.customers
      end
      customers.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def search_customers
      results = Array.new
        results = @company.customers.by_name(params[:sSearch_0]).by_email(params[:sSearch_1]).by_created_by(params[:sSearch_2])
      results
    end
    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name credit_limit email primary_phone_number name]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

    def format_currency(amt)
      unit = @company.country.currency_code
      number_to_currency(amt, :unit => unit+" ", :precision=> 2)
    end

end