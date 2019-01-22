class EmployeeGoalsController < ApplicationController

  layout "payroll"#, :except => [:show]
  # GET /employee_goals
  # GET /employee_goals.xml
  def index
    @menu = 'Performance Management'
    @page_name = 'Goals for Employee'
    @search = @company.employee_goals.search(params[:search])
    @employee_goals = @search.page(params[:page]).per(10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @employee_goals }
    end
  end

  def emp_goal
    @menu = 'Self Service'
    @page_name = 'My performance'
    @employee_goals = @current_user.employee_goals.page(params[:page]).per(10)
  end

  # GET /employee_goals/1
  # GET /employee_goals/1.xml
  def show
    @menu = 'Performance Management'
    @page_name = 'View Goal'
    @employee_goal = EmployeeGoal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @employee_goal }
    end
  end

  # GET /employee_goals/new
  # GET /employee_goals/new.xml
  def new
    @menu = 'Performance Management'
    @page_name = 'Create New Goal '
    @employee_goal = EmployeeGoal.new
    @users = @company.users
    @master_objectives = @company.master_objectives
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @employee_goal }
    end
  end

  # GET /employee_goals/1/edit
  def edit
    @menu = 'Performance Management'
    @page_name = 'Edit Goal'
    @users = @company.users
    @master_objectives = @company.master_objectives
    @employee_goal = EmployeeGoal.find(params[:id])
  end

  # POST /employee_goals
  # POST /employee_goals.xml
  def create
    @employee_goal = EmployeeGoal.new(params[:employee_goal])
    @employee_goal.company_id = @company.id
    @employee_goal.created_by = @current_user.id
    respond_to do |format|
      if @employee_goal.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " new employee goal for #{@employee_goal.for_employee_name} from date #{@employee_goal.from_date} to
         #{@employee_goal.to_date}", "created", @current_user.branch_id) 
        flash[:success]= "Employee goal was successfully created."
        format.html { redirect_to(@employee_goal) }
        format.xml  { render :xml => @employee_goal, :status => :created, :location => @employee_goal }
      else
        @menu = 'Performance Management'
        @page_name = 'Create New Goal '
        @users = @company.users
        @master_objectives = @company.master_objectives
        format.html { render :action => "new" }
        format.xml  { render :xml => @employee_goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /employee_goals/1
  # PUT /employee_goals/1.xml
  def update
    @employee_goal = EmployeeGoal.find(params[:id])

    respond_to do |format|
      if @employee_goal.update_attributes(params[:employee_goal])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " employee goal for #{@employee_goal.for_employee_name} from date #{@employee_goal.from_date} to
         #{@employee_goal.to_date}", "updated", @current_user.branch_id) 
        
        format.html { redirect_to(@employee_goal,:notice => 'Employee goal was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Performance Management'
        @page_name = 'Edit Goal '
        format.html { render :action => "edit" }
        format.xml  { render :xml => @employee_goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_goals/1
  # DELETE /employee_goals/1.xml
  def destroy
    @employee_goal = EmployeeGoal.find(params[:id])
    @employee_goal.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " employee goal for #{@employee_goal.for_employee_name} from date #{@employee_goal.from_date} to
    #{@employee_goal.to_date} is marked as deleted", "deleted",@current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(employee_goals_url) }
      format.xml  { head :ok }
    end
  end
end
