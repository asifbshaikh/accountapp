class PbreferralDatatable
  include Rails.application.routes.url_helpers 
  include ActionView::Helpers
  include ActionView::Context
  # include ActionView::PartialRenderer
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user)
    @view =view
    @company = company
    @user = user
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => pbreferrals.count,
      :iTotalDisplayRecords => pbreferrals.total_count, 
      :aaData => data
    }
  end

  private
    def data
      pbreferrals.map do |pbreferral|
        [
          pbreferral.email,
          pbreferral.get_status,
          pbreferral.earning, 
        ]
      end
    end

    # def twitter_dropdown(product, batches)
    #   bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
    #     b.bootstrap_button "View", product_path(product),  :class => "btn btn-white btn-sm dropdown-toggle"
    #     b.link_to "Edit", edit_product_path(product)
    #     b.content_tag :li,"",:class => "divider"
    #     b.link_to "Delete", product, :method => "delete", :confirm =>"Are you sure?" 
    #     if @company.plan.is_inventoriable? && product.batch_enable? && batches.size > 0
    #       b.link_to "Add batch details", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal-batch-details#{product.id}", :class=>"batch-link#{product.id}"
    #     end
    #   end      
    # end

    def pbreferrals
      @pbreferrals ||= fetch_pbreferrals
    end

    def fetch_pbreferrals
      if params[:sSearch].present?
        search_params = "%#{params[:sSearch]}%"
        @status = Pbreferral.get_status_id(search_params)
        pbreferrals = @company.pbreferrals.where("email like ? or status like ? or earning like ?", search_params, @status, search_params)
      else
        pbreferrals = @company.pbreferrals
      end
      pbreferrals = pbreferrals.order("#{sort_column} #{sort_direction}")
      pbreferrals = pbreferrals.page(page).per(per_page)
    end

    
    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[email status earning]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
    
end