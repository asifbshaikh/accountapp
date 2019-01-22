class Admin::UsersController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
skip_after_filter :intercom_rails_auto_include, :intercom_events
  def index

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @users }
      format.json { render :json => UsersDatatable.new(view_context)}
    end
  end
  def users_last_month
    @menu = 'Users'
    @page_name = 'List of users'
    @users = User.last_month
  end
  def users_last3_month
    @menu = 'Users'
    @page_name = 'List of users'
    @users = User.last3_month
  end
  def users_last6_month
    @menu = 'Users'
    @page_name = 'List of users'
    @users = User.last6_month
  end
  def users_last9_month
    @menu = 'Users'
    @page_name = 'List of users'
    @users = User.last9_month
  end
  def users_last12_month
    @menu = 'Users'
    @page_name = 'List of users'
    @users = User.last12_month
  end
 
    def show
    @menu = 'User'
    @page_name = 'User Detail'
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

end
