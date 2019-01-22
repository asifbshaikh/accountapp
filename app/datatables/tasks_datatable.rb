class TasksDatatable
  include Rails.application.routes.url_helpers 
  include ActionView::Helpers
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
      :iTotalRecords => tasks.count,
      :iTotalDisplayRecords => tasks.total_count, 
      :aaData => data
    }
  end

  private

    def data
      if params[:project].present?
       tasks.map do |task|
          [
            truncate(task.description, :length => 50), 
            h(task.due_date),
            task.assigned_user,
            task.created_by_user,
            task.priority_name
          ]
        end
      else
        tasks.map do |task|
          [
            truncate(task.description, :length => 50), 
            task.project_id.blank? ? "Not Available" : task.project.name,
            h(task.due_date),
            task.priority_name,
            twitter_dropdown(task)
          ]
        end
      end
    end
    

    def twitter_dropdown(task)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "Edit",edit_task_path(task),  :class => "btn btn-white btn-sm dropdown-toggle"
          
          if task.task_status == 0
            b.link_to "Mark Complete", "/tasks/mark_complete?id=#{task.id}"
          else
            b.link_to "Mark Incomplete", "/tasks/mark_complete?id=#{task.id}"
          end
          b.content_tag :li,"",:class => "divider" 
          b.link_to "Delete", task, :method => "delete", :confirm =>"Are you sure?" 
      end      
    end

    def tasks
      if params[:project].present?
       @tasks ||= fetch_project_tasks
      else
       @tasks ||= fetch_tasks
      end
    end

    def fetch_tasks
      if params[:sSearch].present?
        tasks = @company.tasks.where("description like :search or due_date like :search", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? 
        tasks = search_tasks
      else
        tasks = Task.user_tasks(@user.id, @company.id)
      end
      tasks = tasks.order("#{sort_column} #{sort_direction}")
      tasks = tasks.page(page).per(per_page)
      tasks
    end

    def fetch_project_tasks
      if params[:sSearch].present?
        tasks = @company.tasks.where("description like :search or due_date like :search and project_id = #{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
      else
        tasks = Task.user_tasks(@user.id, @company.id).by_project(params[:project])
      end
      tasks = tasks.order("#{sort_column} #{sort_direction}")
      tasks = tasks.page(page).per(per_page)
      tasks
    end
   

    def search_tasks
      results = Array.new
      if !params[:sSearch_2].blank?
        date_range=params[:sSearch_2].split("~")
        start_date= date_range[0].blank? ? @financial_year.start_date : date_range[0].to_date
        end_date= date_range[1].blank? ? @financial_year.end_date : date_range[1].to_date
      else
        start_date=@financial_year.start_date
        end_date=@financial_year.end_date
      end
      
      results = @company.tasks.by_description(params[:sSearch_0]).by_date_range(start_date, end_date).by_project(params[:sSearch_1]).by_priority(params[:sSearch_3])
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[description due_date]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end