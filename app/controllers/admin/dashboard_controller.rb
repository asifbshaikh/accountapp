class Admin::DashboardController < ApplicationController

  layout "admin"
  skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user, :end_session
  skip_after_filter :intercom_rails_auto_include, :intercom_events
  
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workstreams }
      format.json { render :json => AdminDashboardDatatable.new(view_context,@current_user)}
    end
  end

  def today
    @menu = "Admin"
    @page_name = "Dashboard"
    @customer_relationships = CustomerRelationship.order("next_contact_date DESC").where(:next_contact_date => Time.zone.now.to_date).page(params[:page]).per(20)
  end

  def past
    @menu = "Admin"
    @page_name = "Dashboard"
    @customer_relationships = CustomerRelationship.order("next_contact_date DESC").where("next_contact_date < ?",  Time.zone.now.to_date).page(params[:page]).per(20)
  end
  def upcoming
    @menu = "Admin"
    @page_name = "Dashboard"
    @customer_relationships = CustomerRelationship.order("next_contact_date DESC").where("next_contact_date > ?", Time.zone.now.to_date).page(params[:page]).per(20)
  end
end
