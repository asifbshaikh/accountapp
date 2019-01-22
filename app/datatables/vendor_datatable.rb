class VendorDatatable
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
      :iTotalRecords => vendors.count,
      :iTotalDisplayRecords => vendors.total_count,
      :aaData => data
    }
  end

  private
    def data
      vendors.map do |vendor|
        [
          link_to(vendor.name, vendor_path(vendor)),
          h(vendor.email),
          h(vendor.primary_phone_number),
          twitter_dropdown(vendor)
        ]
      end
    end

    def twitter_dropdown(vendor)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white dropdown-toggle btn-sm"}) do |b|
          b.bootstrap_button "View", vendor_path(vendor),  :class => "btn btn-white dropdown-toggle btn-sm"
          # b.link_to "Edit", edit_vendor_path(vendor)
          b.content_tag :li,"",:class => "divider"
          b.link_to "Delete", vendor, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def vendors
      @vendors ||= fetch_vendors
    end

    def fetch_vendors

      if params[:sSearch].present?
        vendors = @company.vendors.where("name like :search or email like :search or primary_phone_number like :search", :search => "%#{params[:sSearch]}%")
      elsif params[:sSearch_0].present?
        vendors = search_vendors
      else
        
        vendors = @company.vendors
      end
      vendors.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def search_vendors
      results = Array.new
      if params[:sSearch_0].present?
        results = @company.vendors.where("name like ?", "%#{params[:sSearch_0]}%")
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
      columns = %w[name email primary_phone_number name]
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