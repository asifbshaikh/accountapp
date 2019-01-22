class TimesheetsController < ApplicationController
  # before_filter :menu_title
  # layout "payroll"#, :except => [:show]
  # GET /timesheets
  # GET /timesheets.xml
  def index
    # @search = @company.timesheets.search(params[:search])
    # @timesheets = @search.order("created DESC").page(params[:page]).per(20)
    @timesheets = @company.timesheets.order("created_at DESC").page(params[:page]).per(20)
    @timesheet = Timesheet.new_timesheet
    @tasks = @company.tasks #Task.where(:company_id => @company.id, :billable => true)
    @week = Time.zone.now.beginning_of_week.to_date
    if params[:dated_on].blank?
      @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
    else
      dated_on = params[:dated_on].to_date
      @dates = (dated_on.beginning_of_week.to_date..dated_on.end_of_week.to_date).to_a
    end

    respond_to do |format|
      format.json {render :json=>TimesheetDatatable.new(view_context, @company, @current_user)}
      format.html # index.html.erb
      format.xml  { render :xml => @timesheets }
    end
  end

  # GET /timesheets/1
  # GET /timesheets/1.xml
  def show
    @timesheet = Timesheet.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @timesheet }
    end
  end

  def new
    @timesheet = Timesheet.new_timesheet
    @tasks = @company.tasks.by_project(params[:project_id]) #Task.where(:company_id => @company.id, :billable => true)
    @week = Time.zone.now.beginning_of_week.to_date
    if params[:dated_on].blank?
      @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
    else
      dated_on = params[:dated_on].to_date
      @dates = (dated_on.beginning_of_week.to_date..dated_on.end_of_week.to_date).to_a
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @timesheets }
    end
  end

  def new_weekly
    @timesheets = @company.timesheets.order("created_at DESC").page(params[:page]).per(20)
    @timesheet = Timesheet.new_timesheet
    @tasks = @company.tasks #Task.where(:company_id => @company.id, :billable => true)
    @week = Time.zone.now.beginning_of_week.to_date
    if params[:dated_on].blank?
      @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
    else
      dated_on = params[:dated_on].to_date
      @dates = (dated_on.beginning_of_week.to_date..dated_on.end_of_week.to_date).to_a
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @timesheets }
    end
  end
  # GET /timesheets/1/edit
  def edit
    @tasks = @company.tasks
    @timesheet = Timesheet.find(params[:id])
    @week = @timesheet.start_date.beginning_of_week
  end

  # POST /timesheets
  # POST /timesheets.xml
  def create
    @timesheets = @company.timesheets.order("created_at DESC").page(params[:page]).per(20)
    @timesheet = Timesheet.create_timesheet(params, @company, @current_user)
    @tasks = @company.tasks
    @week = params[:timesheet][:start_date].to_date.beginning_of_week
    respond_to do |format|
      if @timesheet.save
        flash[:success]= "Timesheet successfully created."
        format.html { redirect_to timesheets_path }
        format.xml  { render :xml => @timesheet, :status => :created, :location => @timesheet }
      else
       @week = params[:timesheet][:start_date].to_date.beginning_of_week
      if params[:dated_on].blank?
        @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
      else
        dated_on = params[:dated_on].to_date
        @dates = (dated_on.beginning_of_week.to_date..dated_on.end_of_week.to_date).to_a
      end
       @tasks = @company.tasks
        format.html { render :action => "index" }
        format.xml  { render :xml => @timesheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_weekly_timesheet
    @timesheets = @company.timesheets.order("created_at DESC").page(params[:page]).per(20)
    @timesheet = Timesheet.create_weekly_timesheet(params, @company, @current_user)
    @tasks = @company.tasks
    @week = params[:timesheet][:start_date].to_date.beginning_of_week
    @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
    if @timesheet.valid?
      @timesheet.save
      redirect_to "/timesheets/new_weekly?dated_on=#{params[:dated_on]}"
    else
      @tasks = @company.tasks #Task.where(:company_id => @company.id, :billable => true)
      if params[:dated_on].blank?
        @dates = (Time.zone.now.beginning_of_week.to_date..Time.zone.now.end_of_week.to_date).to_a
      else
        dated_on = params[:dated_on].to_date
        @dates = (dated_on.beginning_of_week.to_date..dated_on.end_of_week.to_date).to_a
      end
      render :action => "new_weekly"
    end
  end
  # PUT /timesheets/1
  # PUT /timesheets/1.xml
  def update
    @timesheet = Timesheet.find(params[:id])
    @tasks = @company.tasks
    @week = @timesheet.start_date.beginning_of_week
    respond_to do |format|
      if @timesheet.update_attributes(params[:timesheet])
        format.html { redirect_to(timesheets_path, :notice => 'Timesheet was successfully updated.') }
        format.xml  { head :ok }
      else
        @week = params[:timesheet][:start_date].to_date.beginning_of_week
        @tasks = @company.tasks
        format.html { render :action => "edit" }
        format.xml  { render :xml => @timesheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timesheets/1
  # DELETE /timesheets/1.xml
  def destroy
    @timesheet = Timesheet.find(params[:id])
    @timesheet.destroy
    respond_to do |format|
      format.html { redirect_to(timesheets_url) }
      format.xml  { head :ok }
    end
  end
 def add_row
    @timesheet_line_item = TimesheetLineItem.new
    @tasks = @company.tasks
    respond_to do |format|
      format.js
    end
  end
  def report
    @tasks = Timesheet.get_timesheet_record(params,@company, @financial_year)
    @users = @company.users
    if !params[:name].blank?
      @user_id = params[:name]
    end
    @start_date = params[:start_date].blank? ? @financial_year.start_date.to_date : params[:start_date]
    @end_date = params[:end_date].blank? ? Time.zone.now : params[:end_date]
  end
  def remove_line_item
	 #we just want this method to pass to the erb
  end
  # method to change the week
  def change_week
    @tasks = @company.tasks
    @timesheet = Timesheet.new
    @timesheet.timesheet_line_items.build

    cur_week = params[:date].to_date
    @week = cur_week.beginning_of_week
    if params[:cur_week]== "next_week"
     @week = @week+ 7.days
    else
     @week = @week- 7.days
    end
    respond_to do |format|
     format.js
    end
  end
private
   def menu_title
     @menu = "Timesheets"
     @page_name ="Book time"
   end
end
