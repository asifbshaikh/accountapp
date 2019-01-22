class CompanyAssetsDatatable
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
      :iTotalRecords => company_assets.count,
      :iTotalDisplayRecords => company_assets.total_count, 
      :aaData => data
    }
  end

  private

    def data
      company_assets.map do |asset|
        [
         asset.asset_tag,
          truncate(asset.description, :length => 20),
          h(asset.purchase_date.strftime("%d %b %y")),
          User.find(asset.assigned_to).first_name,
        ]
      end
    end
    

    # def twitter_dropdown(asset)
    #   bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-s dropdown-toggle"}) do |b|
    #       b.bootstrap_button "View",message_path(message),  :class => "btn btn-white btn-s dropdown-toggle"
    #       b.link_to "Delete", message, :method => "delete", :confirm =>"Are you sure?" 
    #         # <li class="divider"></li>
    #         # <li><a rel="nofollow" data-method="delete" data-confirm="Are you sure?" href= "/invoices/<%= invoice.id%>" >Delete</a></li>

    #   end      
    # end

    def company_assets
      @company_assets ||= fetch_company_assets
    end

    def fetch_company_assets
      if params[:sSearch].present?
        company_assets = @company.company_assets.where("subject like :search or description like :search", :search => "%#{params[:sSearch]}%")
      else
        company_assets = @company.company_assets
      end
      company_assets = @company.company_assets.order("#{sort_column} #{sort_direction}")
      company_assets = company_assets.page(page).per(per_page)
      company_assets
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[asset_tag description purchase_date  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end