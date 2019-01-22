class HolidaysController < ApplicationController
  # layout "payroll" #,:except => [:show]
  # GET /holidays
  # GET /holidays.xml
   rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    respond_to :html, :json
    
  def index
    @menu = "Organisation Settings"
    @page_name = "Manage Holiday"
    @search = @company.holidays.search(params[:search])
    @holidays = @search.page(params[:page]).per(20)
    # @holiday = Holiday.new
    
    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @holidays }
    end
  end
  
  def holiday_list
  @menu = "Organisation "
    @page_name = "Holiday List"
    @search = @company.holidays.search(params[:search])
    @holidays = @search.page(params[:page]).per(20)
    respond_to do |format|
      format.html # holiday_list.html.erb
      format.xml  { render :xml => @holiday_list }
    end 
  end
  
  # GET /holidays/1
  # GET /holidays/1.xml
  def show
    @menu = "Organisation Settings"
    @page_name = "View Holiday"
    @holiday = Holiday.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @holiday }
    end
  end
  
  
  #GET / holidays/new
  def new
    @menu = "Organisation Settings"
    @page_name = "Manage Holiday"
    @holiday = Holiday.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @holidays }
    end
  end
  # GET /holidays/1/edit
  def edit
    @menu = "Organisation Settings"
    @page_name = "Manage Holiday"
    @users = @company.users
    @holiday = Holiday.find(params[:id])
  end
  
  # POST /holidays
  # POST /holidays.xml
  def create
    @holiday = Holiday.new_holiday(params, @company.id, @current_user)
    @holidays = @company.holidays
    respond_to do |format|
      if @holiday.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " new holiday for #{@holiday.holiday} on date #{@holiday.holiday_date}", "created", @current_user.branch_id)
      end
      format.js { render "create_holiday" }
    end
  end
  
  # PUT /holidays/1
  # PUT /holidays/1.xml
  def update
    @holiday = Holiday.find(params[:id])
    
    respond_to do |format|
      if @holiday.update_attributes(params[:holiday])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " holiday for #{@holiday.holiday} on date #{@holiday.holiday_date}", "updated", @current_user.branch_id)
        format.html { redirect_to(@holiday, :notice => 'Holiday was successfully updated.') }
        # format.xml  { head :ok }
        format.json  { head :ok }
      else
        @menu = "Organisation Settings"
        @page_name = "Manage Holiday"
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @holiday.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@holiday) }
      end
    end
  end
  
  # DELETE /holidays/1
  # DELETE /holidays/1.xml
  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " holiday for #{@holiday.holiday} on date #{@holiday.holiday_date} is marked as deleted", "deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(settings_payroll_path, :notice => "Holiday has been successfully deleted" ) }
      format.xml  { head :ok }
    end
  end
  
   private
    def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to '/settings/payroll'
    end
end
