class JobsController < ApplicationController
  layout "payroll", :except => [:show]
  # GET /jobs
  # GET /jobs.xml
  def index
    @menu = 'Organisation Settings'
    @page_name = 'Manage Job Title'
    @users = User.users_in_company(session[:current_user_id])
    @jobs = Job.all
    @job = Job.new

    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @menu = 'Organisation Settings'
    @page_name = 'View Job Title'
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @menu = 'Organisation Settings'
    @page_name = 'Edit Job Title'
    @user = User.users_in_company(session[:current_user_id])
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    @job.user_id = session[:current_user_id]
    respond_to do |format|
      if @job.save
        @jobs = Job.all
        @job = Job.new
        format.html { redirect_to jobs_path }

        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
