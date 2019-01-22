class LeadDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, current_user)
    @view =view
    @current_user = current_user
    @current_tab = params[:tab_ref]
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => leads.count,
      :iTotalDisplayRecords => leads.total_count,
      :aaData => data
    }
  end

  private
    def data
      leads.map do |lead|
        [
          link_to(lead.name, admin_lead_path(lead.id)),
          lead.organisation_name,
          (lead.mobile),
          (lead.email),
          #(lead.channel_name),
          (lead.next_call_date.strftime("%d-%m-%Y") unless lead.next_call_date.blank?),
          (lead.created_at.to_date.strftime("%d-%m-%Y")),
          (lead.get_status),
          h(lead.assigned_to_name),
          twitter_dropdown(lead)
        ]
      end
    end

    def leads
      @leads ||= fetch_leads
    end

    # Interested and might buy tab are merged together in Admin lead and add new tab unassigned and no response.
    # Date:7-10-2016 By Ashish Shal
    def fetch_leads
      if @current_tab == "interested"
        leads = Lead.qualified_leads(params[:sSearch])
      elsif @current_tab == "unassigned"
        leads = Lead.open_leads(params[:sSearch])
      elsif @current_tab == "won_leads"
        leads = Lead.won_leads(params[:sSearch])
      elsif @current_tab == "lost_leads"
        leads = Lead.lost_leads(params[:sSearch])
      elsif @current_tab == "junk"
        leads = Lead.junk_leads(params[:sSearch])
      elsif @current_tab == "my_leads"
        leads = Lead.my_leads(@current_user, params[:sSearch])
      elsif @current_tab == "all_leads"
        leads = Lead.all_leads(params[:sSearch])
      end
      
      leads = leads.order("#{sort_column} #{sort_direction}")
      leads = leads.page(page).per(per_page)
    end

    # def search_leads
    #   results = Array.new
    #   results = Lead.by_name(params[:sSearch_0]).by_mobile(params[:sSearch_1]).by_email(params[:sSearch_2]).by_channel(params[:sSearch_3]).by_campaign(params[:sSearch_4]).by_status(params[:sSearch_5]).by_assigned(params[:sSearch_6])
    #   results
    # end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[created_at]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

    private
      def twitter_dropdown(lead)
        bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-xs dropdown-toggle"}) do |b|
          b.bootstrap_button "View", admin_lead_path(lead),  :class => "btn btn-white btn-xs dropdown-toggle"
          b.link_to "Edit", edit_admin_lead_path(lead)
          if lead.open?
            b.link_to "Assign to me", {action: :assign, id: lead.id}, remote: true
          end
          if lead.assigned?
            b.link_to "Mark as Junk", {action: :junk, id: lead.id}, remote: true
            b.link_to "Mark as Qualified", {action: :qualified, id: lead.id}, remote: true
          end
          #b.link_to "Convert To Invoice", {:controller => :invoices, :action => :converted_from_lead, :lead_id => lead.id}
          #b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{lead.id}"
        end
      end

end