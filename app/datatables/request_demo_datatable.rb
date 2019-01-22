class RequestDemoDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, current_user)
    @view =view
    @current_user = current_user
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
            (lead.mobile),
            (lead.email),
            (lead.created_at.to_date.strftime("%d-%m-%Y")),
            (lead.next_followup.strftime("%d-%m-%Y") unless lead.next_followup.blank?),
            h(lead.assigned_to_name)
          ]

      end
    end


    def leads
      @leads ||= fetch_leads
    end

    def fetch_leads
  
        if params[:tab_ref] == "all_leads"
          if params[:sSearch].present?
            status_id = Lead.get_status_id(params[:sSearch])
            leads = Lead.where(:deleted => false, :converted_to_trial => false).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.email like :search or channels.channel_name like :search or leads.next_call_date like :search or leads.status = :status ", :search => "%#{params[:sSearch]}%", :status => status_id)
          elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
            leads =  search_leads
          else

            #code for fetching all demo leads based on  trial demo status 2 and activity not completed.(activity_status=>0)
            leads=Lead.select("leads.id,leads.name,leads.mobile,leads.email,lead_activities.created_at,lead_activities.next_followup,leads.assigned_to").joins(:lead_activities).where(:lead_activities=>{next_activity: 2,:activity_status=>0})
          end
        end
          if params[:tab_ref] == "todays_leads"
            if params[:sSearch].present?
          status_id = Lead.get_status_id(params[:sSearch])
          leads = Lead.where(:deleted => false, :converted_to_trial => false, :assigned_to => @current_user.id).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.email like :search or channels.channel_name like :search or leads.next_call_date like :search or leads.status = :status ", :search => "%#{params[:sSearch]}%", :status => status_id)
            else

          leads=Lead.select("leads.id,leads.name,leads.mobile,leads.email,lead_activities.created_at,lead_activities.next_followup,leads.assigned_to").joins(:lead_activities).where(:lead_activities=>{next_activity: 2,:activity_status=>0,:next_followup=> Date.today.strftime("%Y-%m-%d")})
            end

          elsif params[:tab_ref] == "upcoming_leads"
            if params[:sSearch].present?
          status_id = Lead.get_status_id(params[:sSearch])
          leads = Lead.where(:deleted => false, :converted_to_trial => false, :created_by => @current_user.id).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.email like :search or channels.channel_name like :search or leads.next_call_date like :search or leads.status = :status ", :search => "%#{params[:sSearch]}%", :status => status_id)
            else
             leads=Lead.select("leads.id,leads.name,leads.mobile,leads.email,lead_activities.created_at,lead_activities.next_followup,leads.assigned_to").joins(:lead_activities).where("lead_activities.next_activity=? and lead_activities.activity_status=? and lead_activities.next_followup > ?",2,0,Date.today.strftime("%Y-%m-%d"))
                     
            end
          elsif params[:tab_ref] == "past_leads"
            if params[:sSearch].present?
          status_id = Lead.get_status_id(params[:sSearch])
          leads = Lead.where(:deleted => false, :converted_to_trial => false, :created_by => @current_user.id).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.email like :search or channels.channel_name like :search or leads.next_call_date like :search or leads.status = :status ", :search => "%#{params[:sSearch]}%", :status => status_id)
            else
          leads=Lead.select("leads.id,leads.name,leads.mobile,leads.email,lead_activities.created_at,lead_activities.next_followup,leads.assigned_to").joins(:lead_activities).where("lead_activities.next_activity=? and lead_activities.activity_status=? and lead_activities.next_followup < ?",2,0,Date.today.strftime("%Y-%m-%d"))
                     
            end
          end
      leads = leads.order("#{sort_column} #{sort_direction}")
      leads = leads.page(page).per(per_page)
    end

    def search_leads
      results = Array.new
      results = Lead.select("leads.id,leads.name,leads.mobile,leads.email,lead_activities.created_at,lead_activities.next_followup,leads.assigned_to").joins(:lead_activities).by_name(params[:sSearch_0]).by_mobile(params[:sSearch_1]).by_email(params[:sSearch_2])
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[lead_activities.next_followup]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end