class Admin::ChannelsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
  skip_after_filter :intercom_rails_auto_include

 def index
 	@menu = "Admin"
 	@page_name = "Channels"
 	@channels = Channel.order("created_at DESC").page(params[:page]).per(20)
 end
 
 def new
 	@menu = "Channels"
 	@page_name = "Add new channel"
 	@channel = Channel.new
 	respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @channels }
    end
 end
 
 def show
    @menu = 'Channels'
    @page_name = 'Channel details'
    @channel = Channel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @channel }
    end
  end

  def edit
    @menu = 'Channel'
    @page_name = 'Edit channel'
    @channel = Channel.find(params[:id])
  end

  def create
    @channel = Channel.new(params[:channel])
    respond_to do |format|
      if @channel.save
        flash[:success]= "channel successfully created."
        format.js {render "admin/leads/create_channel"}
        format.html { redirect_to admin_super_users_url }
        format.xml  { render :xml => @channel, :status => :created, :location => @channel }
      else
         @menu = 'Channel'
         @page_name = 'Create new channel'
         format.js {render "admin/leads/create_channel"}
         format.html { redirect_to admin_super_users_url }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @channel = Channel.find(params[:id])

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        format.html { redirect_to(admin_super_users_url, :notice => 'channel was successfully updated.') }
        format.xml  { head :ok }
      else
     @menu = 'Channels'
    @page_name = 'Edit channel'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to(admin_super_users_url) }
      format.xml  { head :ok }
    end
  end

  def inactive
    @channel = Channel.find(params[:id])
    @channel.mark_inactive
  end

  def active
    @channel = Channel.find(params[:id])
    @channel.mark_active
  end

end
