class UsersDatatable
  include Rails.application.routes.url_helpers 
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view)
    @view =view
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
        users.map do |user|
          
          [
            link_to(user.full_name, admin_user_path(user.id)),
            (user.username),
            (user.email),
            (user.company_name),
            (user.company.plan.display_name),
            (user.get_users_role),
            h(user.last_login_time)
          ]
        end
    end

    def users
      @users ||= fetch_users
    end

    def fetch_users
      if params[:tab_ref] == "all_users"
          if params[:sSearch].present?
           users =  User.where(:deleted => false).joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.where(:deleted => false)
          end

      elsif params[:tab_ref] == "users_last_month"
        if params[:sSearch].present?
           users =  User.last_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.last_month
          end
      elsif params[:tab_ref] == "users_last3_month"
          if params[:sSearch].present?
           users =  User.last3_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.last3_month
          end
      elsif params[:tab_ref] == "users_last6_month"
        if params[:sSearch].present?
           users =  User.last6_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.last6_month
          end
      elsif params[:tab_ref] == "users_last9_month"
        if params[:sSearch].present?
           users =  User.last9_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.last9_month
          end
      elsif params[:tab_ref] == "users_last12_month"
        if params[:sSearch].present?
           users =  User.last12_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.last12_month
          end
      elsif params[:tab_ref] == "all_contacts"
        if params[:sSearch].present?
           users =  User.last12_month.joins({:company => :plan}, :roles).where("roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login_time like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
          else
          users = User.where(:deleted => false)
          end
        
      end
      users = users.order("#{sort_column} #{sort_direction}")
      users = users.page(page).per(per_page)
    end

    def search_users
      owner_array = Role.owner_list
      results = Array.new
      if !params[:sSearch_1].blank?
        results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
      elsif !params[:sSearch_3].blank?
        results = Company.joins(:users=> :assignments).where("users.email like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
      else
      results = Company.by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3]).group("companies.id")
    end
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[last_login_time]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
    
end