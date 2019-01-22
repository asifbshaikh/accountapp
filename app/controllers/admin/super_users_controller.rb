class Admin::SuperUsersController < ApplicationController
  layout "admin"
  skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
  skip_after_filter :intercom_rails_auto_include
    def index
    @menu = 'Admin'
    @page_name = 'User List'
    @super_users = SuperUser.where(:active => true)
    @channels = Channel.all
    @campaigns = Campaign.all
     @channel = Channel.new
     @campaign = Campaign.new
     @super_user = SuperUser.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @super_users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @menu = 'Admin'
    @page_name = 'User Detail'
    @super_user = SuperUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @super_user }
    end
  end

   def new
    @menu = 'Admin'
    @page_name = 'Create New User'
    @super_user = SuperUser.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @super_user }
    end
  end

  # GET /users/1/edit
  def edit
    @menu = 'Admin'
    @page_name = 'Edit User'
    @super_user = SuperUser.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @super_user = SuperUser.new(params[:super_user])
    @super_user.role = "Subadmin"
    respond_to do |format|
      if @super_user.save
        flash[:success]= "User successfully created."
        format.js {render "admin/super_users/create_super_user"}
        # format.html { redirect_to(admin_super_users_url, :notice => 'New user was successfully created.') }
        format.xml  { render :xml => @super_user, :status => :created, :location => @super_user }
      else
        @menu = 'Admin'
        @page_name = 'Create New User'
        format.js {render "admin/super_users/create_super_user"}
        # format.html { render :action => "new" }
        format.xml  { render :xml => @super_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @super_user = SuperUser.find(params[:id])
    @super_user.update_attributes(params[:super_user])
   
    respond_to do |format|
      if @super_user.update_attributes(params[:super_user])
        format.html { redirect_to(admin_super_users_url, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Admin'
        @page_name = 'Edit User'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @super_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @super_user = SuperUser.find(params[:id])
     @super_user.delete
    respond_to do |format|
        flash[:success]= "User deleted successfully "
        format.html { redirect_to(admin_super_users_url) }
        format.xml  { head :ok }
     end
  end

  def restore_user
    @super_user = SuperUser.find(params[:id])
    respond_to do |format|
      if @super_user.restore(@current_user.id)
        format.html { redirect_to(admin_super_users_url) }
        format.xml  { head :ok }
        flash[:success]= "User restored successfully and an email has been send to user."
      end 
     end
  end

  def create_super_user
     @super_user = SuperUser.new(params[:super_user])   
  end

  def inactive_channel
    @channel = Channel.find(params[:id])
    @channel.mark_inactive
  end

  def active_channel
    @channel = Channel.find(params[:id])
    @channel.mark_active
  end

end
