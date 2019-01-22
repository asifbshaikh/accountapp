class ZendeskAuthController < ApplicationController
  include Zendesk::RemoteAuthHelper

  skip_before_filter :login_required, :only => :logout

  def authorize
    redirect_to zendesk_remote_auth_url(:name => @current_user.first_name, :email => current_user.email, :external_id => @current_user.id)
  end

  def logout
    redirect_to logout_url
  end

  protected
  def login_required
    if !logged_in?
      flash[:notice] = 'You must log in to access the support site.'
      store_location
      redirect_to login_path
    end
  end
end
