class EmployeeDatatable < ActionView::Base
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
      :iTotalRecords => users.count,
      :iTotalDisplayRecords => users.total_count,
      :aaData => data
    }
  end

  private
    def data
      data_arr = []
      users.each do |user|
          row=[]
          content=''

          content += link_to(user.full_name, user_path(user.id))
          content += content_tag :div, :class=>'modal fade', :id=>"modal#{user.id}" do
            @view.render(:partial=>"/users/modal_password.html.erb",:locals=> {:user=>user})
          end
          row<<content
          row<< (user.role_name)
          row<<(user.email)
          !user.last_login_time.nil? ? row<< h(user.last_login_time) : row<< 'Never'

          row<<twitter_dropdown(user)
      
          data_arr<<row
          
      end
      data_arr
    end


    def users
      @workstreams ||= fetch_users
    end

    def fetch_users
      if params[:tab_ref] == "inactive"
        users = @company.inactive_users.includes(:roles)
      else
        users = @company.users.includes(:roles)
      end
      users = users.order("#{sort_column} #{sort_direction}")
      users = users.page(page).per(per_page)
    end


     def twitter_dropdown(user)

      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "Action", "",  :class => "btn btn-white btn-sm dropdown-toggle"
          if !user.deleted?
            b.link_to "Edit", edit_user_path(user), :target => "_blank"
            b.link_to "Change Password", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{user.id}"
            b.content_tag :li,"",:class => "divider"
            b.link_to "Make Inactive", user, :method => "delete", :confirm =>"Are you sure you want to make the Employee inactive?"

          else
            b.link_to "Make Active",users_restore_user_path(:id=>user.id),:confirm =>"Are you sure you want to make the Employee Active?"
          end     
      end
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[id]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

  end