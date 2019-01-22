class MyOrganisationController < ApplicationController
  layout "payroll"
  def index
      @menu = 'My Organisation'
      @page_name = 'Organisation Dashboard'
      @organisation_announcements = @company.organisation_announcements.order("created_at DESC", :limit=>"5") 
  end

   def announcement
     @menu = 'My Organisation'
     @page_name = 'Organisation Dashboard'
     @organisation_announcements = @company.organisation_announcements.order("created_at DESC", :limit=>"5")
    
    respond_to do |format|
      format.html # announcement.html.erb
    end
  end

def holiday_list
  @menu = "My Organisation "
  @page_name = "Organisation Dashboard"
  @holidays = @company.holidays.page(params[:page]).per(20)
    respond_to do |format|
      format.html # holiday_list.html.erb
      format.xml  { render :xml => @holiday_list }
    end 
  end
  def policy_document
  	@menu = "My Organisation"
    @page_name = "Organisation Dashboard"
    @policy_documents = @company.policy_documents.order("uploaded_file_file_name desc").page(params[:page]).per(20)
    @policy_document = PolicyDocument.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @policy_documents }
    end
  end

end
