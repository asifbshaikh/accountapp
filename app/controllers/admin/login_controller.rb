class Admin::LoginController < ApplicationController

  layout 'login'
  #to skip checking the authentication and authorization.
  skip_before_filter  :company_from_subdomain, :current_financial_year, :authorize_action, :authenticate, :company_active?, :check_if_allow, :mix_panel_track, :current_financial_year
  skip_before_filter :check_active_session?, :only => :index

  def index
  end

  def authenticate
    if request.post?
      super_user = SuperUser.authenticate(params[:username], params[:password])
      if super_user
       session[:current_super_user_id] = super_user.id
       session[:super_user_name]= super_user.username
       session[:last_login] = super_user.last_login
       session[:company_id] = 1
       super_user.update_attribute(:last_login, Time.zone.now)
       respond_to do |format|
         format.html {redirect_to "/admin/dashboard"}
         flash[:notice] = "login successfully as admin"
       end
      else
         flash[:error] = "Please enter valid username/password.".html_safe
        redirect_to("/admin/login/index")
      end
    else
     flash.now[:notice] = "Please enter valid username/password"
    end

  end

  def signout
    session[:current_super_user_id] = nil
    session[:super_user_name] = nil
    reset_session
    redirect_to admin_login_index_url
    flash[:error] = "Are you admin ? Then prove it !!"
  end

end
