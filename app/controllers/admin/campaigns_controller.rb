class Admin::CampaignsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
 skip_after_filter :intercom_rails_auto_include

 def index
 	@menu = "Admin"
 	@page_name = "Campaigns"
 	@campaigns = Campaign.order("start_date DESC").page(params[:page]).per(20)
 end
 
 def new
 	@menu = "Campaigns"
 	@page_name = "Create new campaign"
 	@campaign = Campaign.new
 	respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @campaigns }
    end
 end
 
 def show
    @menu = 'Campaigns'
    @page_name = 'campaign details'
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @campaign }
    end
  end

  def edit
    @menu = 'Campaign'
    @page_name = 'Edit campaign'
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    respond_to do |format|
      if @campaign.save
        flash[:success]= "campaign successfully created."
        format.js {render "admin/leads/create_campaign"}
        format.html { redirect_to admin_super_users_url }
        format.xml  { render :xml => @campaign, :status => :created, :location => @campaign }
      else
         @menu = 'campaign'
         @page_name = 'Create new campaign'
         format.js {render "admin/leads/create_campaign"}
         format.html { redirect_to admin_super_users_url }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        format.html { redirect_to(admin_super_users_url, :notice => 'campaign was successfully updated.') }
        format.xml  { head :ok }
      else
     @menu = 'Campaign'
    @page_name = 'Edit campaign'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to(admin_super_users_url) }
      format.xml  { head :ok }
    end
  end


end
