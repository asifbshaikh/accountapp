class ReportDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view)
    @view = view
  end


  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => tasks.count,
      :iTotalDisplayRecords => tasks.size,
      :aaData => data
    }
  end

  private
    def data
      if params[:tab_ref] == "task_delay_companies"
        tasks.map do |task|
        [
          (task.company.name),
          (CustomerRelationship.get_activity(task.next_activity)),
          (task.next_contact_date),
          (task.completed_date),
          h(task.completed_date - task.next_contact_date)
        ]
        end
      elsif params[:tab_ref] == "task_delay_leads"
        tasks.map do |task|
        [
          link_to(task.lead.name),
          (Lead.get_activity(task.next_activity)),
          (task.lead.assigned_to_name),
          (task.next_followup),
          (task.completed_date),
          h(task.completed_date - task.next_followup)
        ]
        end
      end
    end

    def tasks
      @tasks ||= fetch_tasks
    end

    def fetch_tasks
      if params[:tab_ref] == "task_delay_companies"
        tasks = CustomerRelationship.get_delay_activities
      elsif params[:tab_ref] == "task_delay_leads"
        tasks = LeadActivity.get_task_delay_activities
      end
      tasks
    end

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