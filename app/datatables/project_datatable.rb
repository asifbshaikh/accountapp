class ProjectDatatable

  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper

  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user)
    @view =view
    @company = company
    @user = user
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => projects.count,
      :iTotalDisplayRecords => projects.total_count,
      :aaData => data
    }
  end

  private

    def data
      if params[:ongoingprj].present?
        projects.map do |project|
          [
            link_to(project.name, project_path(project)),
            h(project.start_date),
            content_tag(:span, format_currency(project.estimated_cost), :class=>"pull-right"),
            h(project.created_by_user),
            project.get_status,
            twitter_dropdown(project)
          ]
        end
      elsif params[:completedprj].present?
        projects.map do |project|
          [
            link_to(project.name, project_path(project)),
            h(project.start_date),
            content_tag(:span, format_currency(project.estimated_cost), :class=>"pull-right"),
            h(project.created_by_user),
            project.get_status,
            twitter_dropdown(project)
          ]
        end
      end
    end

    def twitter_dropdown(project)
      bootstrap_button_dropdown(:split => true, button_options: { class: "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", project_path(project),  class: "btn btn-white btn-sm dropdown-toggle"
        if @user.owner?
          b.link_to "Edit", edit_project_path(project)
          if !project.completed?
            b.link_to "Mark Complete", "/projects/mark_complete?id=#{project.id}"
          end
          b.content_tag :li,"",:class => "divider"
          b.link_to "Delete", project, :method => "delete", :confirm =>"Are you sure?"
        end
      end
    end

    def projects
      if params[:ongoingprj].present?
        @projects = fetch_ongoing_projects
      elsif params[:completedprj].present?
        @projects = fetch_completed_projects
      end
    end

    def fetch_ongoing_projects
      if params[:sSearch].present?
        projects = @company.projects.where("name like :search or start_date like :search or estimated_cost like :search and status = #{params[:ongoingprj]} ", :search => "%#{params[:sSearch]}%")
      else
        projects = @company.projects.includes(:user).where(:status => false)
      end
      projects.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def fetch_completed_projects
      if params[:sSearch].present?
        projects = @company.projects.where("name like :search or start_date like :search or estimated_cost like :search and status = #{params[:completedprj]} ", :search => "%#{params[:sSearch]}%")
      else
        projects = @company.projects.includes(:user).where(:status => true)
      end
      projects = projects.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end


    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name start_date estimated_cost created_by status]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end