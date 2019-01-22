class WorkstreamDatatable < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include WorkstreamsHelper
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view,company,user)
    @view =view
    @company = company
    @user = user
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => workstreams.count,
      :iTotalDisplayRecords => workstreams.total_count,
      :aaData => data
    }
  end

  private
    def data
      data_arr = []
      workstreams.each do |workstream|
        arr = []
        contents = ''
        contents+= workstream_span(workstream.action_code)
        contents += ' '+ display_workstream_username(workstream.user)+ " " + workstream_action_code(workstream.action_code)+ "  "+
        workstream_action(workstream.action)+ " on " + workstream.action_time.to_s
        arr<<contents
        data_arr<<arr
      end
      data_arr
    end

    def display_workstream_username(action_user)
      (@user.id == action_user.id) ? "You" : action_user.full_name
    end

    def workstreams
      @workstreams ||= fetch_workstreams
    end

    def fetch_workstreams
      Rails.logger.debug "==========WorkstreamDatatable::fetch_workstreams::BEGIN================="
      if params[:tab_ref] == "from_company" && params[:userid] && params[:id]
        workstreams = Workstream.company_workstreams(@company, @user,:userid =>params[:userid],:sSearch=> params[:sSearch], :page => page, :per_page => per_page)
      elsif params[:tab_ref] == "from_company" 
        workstreams = Workstream.company_workstreams(@company, @user, :sSearch=> params[:sSearch], :page => page, :per_page => per_page)
      elsif params[:tab_ref] == "from_admin_company"
        workstreams = Workstream.admin_workstreams(@company, @user, :sSearch=> params[:sSearch], :page => page, :per_page => per_page)
      else
        workstreams = Workstream.all_workstreams(:sSearch=> params[:sSearch], :page => page, :per_page => per_page)
      end
      workstreams
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[action_time action]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

  end