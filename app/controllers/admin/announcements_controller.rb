class Admin::AnnouncementsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user, :menu_title
  skip_after_filter :intercom_rails_auto_include

 def index
  @search = Announcement.search(params[:search])
  @announcements = @search.page(params[:page]).per(20)
 end
 
 def new
  @announcement = Announcement.new
  respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @announcements }
    end
 end
 
 def show
    @announcement = Announcement.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def create
    @announcement = Announcement.create_new(params, @current_user)
    respond_to do |format|
      if @announcement.save
        flash[:success]= "announcement successfully created."
        format.html { redirect_to admin_announcements_url }
        format.xml  { render :xml => @announcement, :status => :created, :location => @announcement }
      else
         format.html { render :action => "new" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @announcement = Announcement.find(params[:id])
    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        format.html { redirect_to(admin_announcement_path, :notice => 'announcement was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    respond_to do |format|
      format.html { redirect_to(admin_announcements_url) }
      format.xml  { head :ok }
    end
  end

 def hide
   ids = [params[:id], *cookies.signed[:hidden_announcement_ids]]
   cookies.permanent.signed[:hidden_announcement_ids] = ids
   respond_to do |format|
     # format.html { redirect_to :back }
     format.js
   end
 end

 private

 def menu_title
   @menu = "Admin"
   @page_name = "Announcement"
 end

end
