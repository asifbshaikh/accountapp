class AdminDashboardDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view,current_user)
    @view = view
    @user = current_user
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
        # @activity = lead.lead_activities.last.next_activity
        if params[:tab_ref] == "todays_leads" || params[:tab_ref] == "my_activities" || params[:tab_ref] == "todays_demo"
          leads.map do |lead|
            if lead.channel_name == "New signup"
               lead_type = "Company"
            else
               lead_type = "Lead"
            end
            @row = []
            lead_activities = LeadActivity.where(:lead_id => lead.id)
              @next_followup = nil
              lead_activities.each do |lead_activity|
                if !lead_activity.next_followup.blank? && lead_activity.activity_status == false && lead_activity.next_followup == Time.zone.now.to_date
                  @next_followup = lead_activity.next_followup.strftime("%d-%m-%Y")
                  @activity = lead_activity.next_activity
                  @next_followup_time = lead_activity.next_follow_up_time
                  break
                end
              end
              @row << @next_followup
              @row << @next_followup_time
          [
            link_to(lead.name, admin_lead_path(lead.id)),
            (lead.get_status),
            (Lead.get_activity(@activity)),
            (@row),
            (lead.mobile),
            h(lead.assigned_to_name)
          ]
          end
        elsif params[:tab_ref] == "upcomming_leads"
          leads.map do |lead|
            if lead.channel_name == "New signup"
               lead_type = "Company"
            else
               lead_type = "Lead"
            end
            @row = []
            unless lead.lead_activities.blank?
              last_activity = lead.lead_activities.last
                unless last_activity.next_followup.blank?
                  if last_activity.next_followup > Time.zone.now.to_date
                  activity = last_activity.next_activity unless last_activity.next_activity.blank?
                  next_followup = last_activity.next_followup
                  next_followup_time = last_activity.next_follow_up_time unless last_activity.next_follow_up_time.blank?
                  end
                end
            end
            @row << next_followup.strftime("%d-%m-%Y") unless next_followup.blank?
            @row << next_followup_time
          [
            link_to(lead.name, admin_lead_path(lead.id)),
            (lead.get_status),
            (Lead.get_activity(activity)),
            (@row),
            (lead.mobile),
            lead.assigned_to_name
          ]
          end
        elsif params[:tab_ref] == "past_leads"
          leads.map do |lead|
            if lead.channel_name == "New signup"
               lead_type = "Company"
            else
               lead_type = "Lead"
            end
            @row = []
            unless lead.lead_activities.blank?
              last_activity = lead.lead_activities.last
                unless last_activity.record_date.blank?
                  if last_activity.record_date < Time.zone.now.to_date
                  activity = last_activity.activity unless last_activity.activity.blank?
                  record_date = last_activity.record_date
                  next_followup_time = last_activity.next_follow_up_time unless last_activity.next_follow_up_time.blank?
                  end
                end
            end
            @row << record_date.strftime("%d-%m-%Y") unless record_date.blank?
            @row << next_followup_time
          [
            link_to(lead.name, admin_lead_path(lead.id)),
            (lead.get_status),
            (Lead.get_activity(activity)),
            (@row),
            (lead.mobile),
            h(lead.assigned_to_name)
          ]
          end
        end
    end

    def leads
      @leads ||= fetch_leads
    end

    def fetch_leads
      if params[:tab_ref] == "my_activities"

        if params[:sSearch].present?
           leads =  Lead.joins(:lead_activities).where(" leads.deleted = ? and leads.assigned_to = ? and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, @user.id, Time.zone.now.to_date,false).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search or channels.channel_name like :search ", :search => "%#{params[:sSearch]}%").group(:lead_id)
          else
          leads = Lead.joins(:lead_activities).where(" leads.deleted = ? and leads.assigned_to = ? and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, @user.id, Time.zone.now.to_date,false).group(:lead_id)
          end
      elsif params[:tab_ref] == "todays_leads"
        if params[:sSearch].present?
           leads =  Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, Time.zone.now.to_date,false).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search or channels.channel_name like :search ", :search => "%#{params[:sSearch]}%").group(:lead_id)
          else
          leads = Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, Time.zone.now.to_date,false).group(:lead_id)
          end
      elsif params[:tab_ref] == "todays_demo"
        if params[:sSearch].present?
           leads =  Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_activity in (?) and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, [2,3,8,18], Time.zone.now.to_date,false).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search or channels.channel_name like :search ", :search => "%#{params[:sSearch]}%").group(:lead_id)
          else
          leads = Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_activity in (?) and lead_activities.next_followup = ? and lead_activities.activity_status = ?", false, [2,3,8,18], Time.zone.now.to_date,false).group(:lead_id)
          end
      elsif params[:tab_ref] == "upcomming_leads"
          if params[:sSearch].present?
           leads =  Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup > ?", false, Time.zone.now.to_date).joins(:channel).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search or channels.channel_name like :search ", :search => "%#{params[:sSearch]}%").group(:lead_id)
          else
          leads = Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup > ?", false, Time.zone.now.to_date).group(:lead_id)
          end
      elsif params[:tab_ref] == "past_leads"
        if params[:sSearch].present?
           leads =  Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup < ? and lead_activities.activity_status = ?", false, Time.zone.now.to_date,false).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search ", :search => "%#{params[:sSearch]}%").group(:lead_id)
          else
          leads = Lead.joins(:lead_activities).where(" leads.deleted = ? and lead_activities.next_followup < ? and lead_activities.activity_status = ?", false, Time.zone.now.to_date,false).group(:lead_id)
          end
      else
        if params[:sSearch].present?
           leads =  Lead.where('deleted = ? and id NOT IN (SELECT DISTINCT(lead_id) FROM lead_activities)',false).where("leads.name like :search or leads.mobile like :search or leads.next_call_date like :search ", :search => "%#{params[:sSearch]}%")
          else
          leads = Lead.never_contacted_leads
          end
      end
      leads = leads.order("#{sort_column} ASC")
      leads = leads.page(page).per(per_page)
    end

    # def search_companies
    #   owner_array = Role.owner_list
    #   results = Array.new
    #   if !params[:sSearch_1].blank?
    #     results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
    #   elsif !params[:sSearch_3].blank?
    #     results = Company.joins(:users=> :assignments).where("users.email like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
    #   else
    #   results = Company.by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3]).group("companies.id")
    # end
    #   results
    # end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[next_followup]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end