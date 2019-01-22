class TasksController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # GET /tasks
  # GET /tasks.xml
  def index
    @todays_tasks = Task.today(@current_user.id, @company.id).user_tasks(@current_user.id, @company.id).page(params[:page]).per(20)
    @week_tasks = Task.this_week(@current_user.id, @company.id).user_tasks(@current_user.id, @company.id).page(params[:page]).per(20)
    @month_tasks = Task.this_month(@current_user.id, @company.id).user_tasks(@current_user.id, @company.id).page(params[:page]).per(20)
    @completed_tasks = Task.closed.user_tasks(@current_user.id, @company.id).page(params[:page]).per(20)

    @task = Task.new
    @project = Project.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.json { render :json => TasksDatatable.new(view_context, @company, @current_user)}
    end
  end

  def new
    @task = Task.new
  end

  def today
    @tasks = Task.today.user_tasks(@current_user.id, @company.id, params[:page])
    @task = Task.new
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html #today.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  def this_week
    @tasks = Task.this_week.user_tasks(@current_user.id, @company.id, params[:page])
    @task = Task.new
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html #this_week.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  def this_month
    @tasks = Task.this_month.user_tasks(@current_user.id, @company.id, params[:page])
    @task = Task.new
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html #this_month.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  def closed
    @tasks = Task.closed.user_tasks(@current_user.id, @company.id, params[:page])
    @task = Task.new
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # closed.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = @company.tasks.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = @company.tasks.find(params[:id])
    @projects = @company.projects.where(:status => false)
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.create_task(params, @company, @current_user)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      if @task.save
        flash[:success]= "Task successfully created."
        Email.task_created(@task, @current_user).deliver
        @task.register_user_action(request.remote_ip, "created", @current_user.branch_id)
        format.html { redirect_to(tasks_url) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        @search = Task.search(params[:search])
        @tasks = @search.where("assigned_to=? ",  @current_user.id).page(params[:page]).per(10)
        format.html { render :action => "index" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
      format.js{render '/projects/add_task'}
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = @company.tasks.find(params[:id])
    @projects = @company.projects.where(:status => false)
    @task.project_id = Project.get_project_id(params[:project_id], @company)
    respond_to do |format|
      if @task.update_attributes( params[:task])
        @task.register_user_action(request.remote_ip, "updated", @current_user.branch_id)
        format.html { redirect_to(tasks_url, :notice=>"Task updated successfully") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end

    end

  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = @company.tasks.find(params[:id])
    @time_line_items = TimeLineItem.where(:task_id=> @task.id)
    @timesheet_line_items = TimesheetLineItem.where(:task_id=> @task.id)
    if @time_line_items.blank? && @timesheet_line_items.blank?
      @task.destroy
      flash[:success] = "Task successfully deleted"
      @task.register_user_action(request.remote_ip, "deleted", @current_user.branch_id)
    else
      flash[:error] = "Task can not be deleted, there are some invoices or timesheet created for this task"
    end
    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end

  #action to mark a task complete
  def mark_complete
    @task = @company.tasks.find(params[:id])
    respond_to do |format|
      if @task.complete_task(@current_user.id)
        @task.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to(tasks_url, :notice => "Task status changed successfully") }
        format.xml  { head :ok }
      else
        @tasks = @company.tasks.page(params[:page]).per(20)
        flash[:error] = "The task status not changed due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @tasks.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_project
    @project = Project.create_project(params, @company.id, @current_user, @financial_year.year.name)
  end

  private

    def record_not_found
      flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
      redirect_to :action=> :index
    end

end
