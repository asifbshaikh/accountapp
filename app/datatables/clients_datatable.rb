class ClientsDatatable
	include Rails.application.routes.url_helpers
  	include ActionView::Helpers
  	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  	delegate :params, :h, :link_to, :number_to_currency, :to => :@view


   	def initialize(view, client_invitation, auditor_id)
    	@view =view
    	@client_invitation = client_invitation
    	@auditor_id = auditor_id
  	end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => clients.count,
      :iTotalDisplayRecords => clients.total_count,
      :aaData => data
    }
  end

  private

    def data
      clients.map do |client|
        [
          client.full_name,
          client.username

        ]
      end
    end



    def clients
      @clients ||= fetch_clients
    end

    def fetch_clients
      if params[:sSearch].present?
        clients = @company.clients.where("name like :search or username like :search  or status like :search ", :search => "%#{params[:sSearch]}%")
      else
        clients = @company.clients
      end
      clients.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end



    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name username status  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
     params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end