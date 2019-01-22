class OrganisationAnnouncementsController < ApplicationController
  layout "payroll" #, :except => [:show]
  # GET /organisation_announcements
  # GET /organisation_announcements.xml
  def index
    @menu = 'Administration'
    @page_name = 'Manage Organization Announcement '
    @users = @company.users
    @search = @company.organisation_announcements.search(params[:search])
    @organisation_announcements = @search.order("created_at DESC", :limit=>"10").page(params[:page]).per(20)
    # @organisation_announcement = OrganisationAnnouncement.new

    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @organisation_announcements }
    end
  end

  def announcement
     @menu = ' Organization'
     @page_name = 'Organization Announcement List'
     @organisation_announcements = @company.organisation_announcements.order("created_at DESC", :limit=>"5")
    
    respond_to do |format|
      format.html # announcement.html.erb
    end
  end
  # GET /organisation_announcements/1
  # GET /organisation_announcements/1.xml
  def show
     @menu = 'Administration'
     @page_name = ' View Organization Announcement'
     @organisation_announcement = OrganisationAnnouncement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organisation_announcement }
    end
  end

 
def new
    @menu = 'Administration'
    @page_name = 'Manage Organization Announcement '
    @users = @company.users
    @organisation_announcement = OrganisationAnnouncement.new

    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @organisation_announcements }
    end
  end

  # GET /organisation_announcements/1/edit
  def edit
    @menu = 'Administration'
    @page_name = 'Edit Organization Announcement '
    @users = @company.users
    @organisation_announcement = OrganisationAnnouncement.find(params[:id])
  end

  # POST /organisation_announcements
  # POST /organisation_announcements.xml
  def create
    @organisation_announcement = OrganisationAnnouncement.new(params[:organisation_announcement])
    @organisation_announcement.company_id = @company.id
    @organisation_announcement.created_by = @current_user.id
    respond_to do |format|
      if @organisation_announcement.save
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " new announcement '#{@organisation_announcement.title}'", "created", @current_user.branch_id)
        flash[:success]= "Announcement successfully created."
         @organisation_announcements = OrganisationAnnouncement.all
         @organisation_announcement = OrganisationAnnouncement.new
        
        format.html { redirect_to organisation_announcements_path }
        format.xml  { render :xml => @organisation_announcement, :status => :created, :location => @organisation_announcement }
      else
        @menu = 'Administration'
        @page_name = 'Manage Organization Announcement '
        @search = @company.organisation_announcements.search(params[:search])
        @organisation_announcements = @search.order("created_at DESC", :limit=>"5")
        @organisation_announcements = @search.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @organisation_announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organisation_announcements/1
  # PUT /organisation_announcements/1.xml
  def update
    @organisation_announcement = OrganisationAnnouncement.find(params[:id])

    respond_to do |format|
      if @organisation_announcement.update_attributes(params[:organisation_announcement])
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " announcement '#{@organisation_announcement.title}'", "updated", @current_user.branch_id)
        format.html { redirect_to(@organisation_announcement, :notice => 'Organisation announcement was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Administration'
        @page_name = 'Edit Organization Announcement '
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organisation_announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organisation_announcements/1
  # DELETE /organisation_announcements/1.xml
  def destroy
    @organisation_announcement = OrganisationAnnouncement.find(params[:id])
    @organisation_announcement.destroy
     Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
     " announcement '#{@organisation_announcement.title}' is marked as deleted", "deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(organisation_announcements_url) }
      format.xml  { head :ok }
    end
  end
end
