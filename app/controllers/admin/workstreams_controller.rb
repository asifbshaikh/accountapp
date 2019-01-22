class Admin::WorkstreamsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
  skip_after_filter :intercom_rails_auto_include, :intercom_events
 def index
    @menu = "Admin"
    @page_name = "Workstreams"
    # @workstreams = Workstream.order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @workstreams }
      format.json { render :json => WorkstreamDatatable.new(view_context,"","")}
    end
  end
end
