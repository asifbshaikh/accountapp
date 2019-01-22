class DepartmentsController < ApplicationController
  # layout "payroll"#, :except => [:show]
  # GET /departments
  # GET /departments.xml
  def index
    @menu = 'Organisation Settings'
    @page_name = 'Manage Department'
    @users = @company.users
    @search = @company.departments.search(params[:search])
    @departments = @search.page(params[:page]).per(20)
    # @department = Department.new
    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @departments }
    end
  end

  # GET /departments/1
  # GET /departments/1.xml
  def show
    @menu = 'Organisation Settings'
    @page_name = 'View Department'
    @department = Department.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @department }
    end
  end

  #/departments/new
  def new
    @menu = 'Organisation Settings'
    @page_name = 'Manage Department'
    @department = Department.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @departments }
    end
  end

  # GET /departments/1/edit
  def edit
    @menu = 'Organisation Settings'
    @page_name = 'Manage Department'
    @users = @company.users
    @department = Department.find(params[:id])
  end

  # POST /departments
  # POST /departments.xml
  def create
    @department = Department.new(params[:department])
    @department.company_id = @company.id
    @department.user_id = @current_user.id
    @department.save
    @departments = @company.departments
    render "create_department"
    # respond_to do |format|
    #   if @department.save
    #       Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    #      " new department #{@department.name} in #{@company.name}", "created", @current_user.branch_id)
    #     flash[:success]= "Department successfully created."
    #     format.html { redirect_to settings_payroll_path }
    #     format.xml  { render :xml => @department, :status => :created, :location => @department }
    #   else
    #     @menu = 'Organisation Settings'
    #     @page_name = 'Manage Department'
    #     @users = @company.users
    #     @search = @company.departments.search(params[:search])
    #     @departments = @search.all
    #     format.html { redirect_to settings_payroll_path }
    #     format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /departments/1
  # PUT /departments/1.xml
  def update
    @department = Department.find(params[:id])

    respond_to do |format|
      if @department.update_attributes(params[:department])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " department #{@department.name} in #{@company.name}", "updated", @current_user.branch_id)
        format.html { redirect_to(@department, :notice => "Department successfully updated.") }
        # format.xml  { head :ok }
        format.json { head :ok }
      else
        @menu = 'Organisation Settings'
        @page_name = 'Manage Department'
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@department) }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.xml
  def destroy
    @department = Department.find(params[:id])
    @users = User.where(:department_id => @department.id)
    if @users.blank?
    @department.destroy
     Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
     " department #{@department.name} in #{@company.name} is marked as deleted", "deleted", @current_user.branch_id)
      flash[:success] = "Department deleted successfully"
      redirect_to settings_payroll_path
    else
      flash[:error] = "There are users still relating to #{@department.name}. This department can not be deleted."
      redirect_to :back
    end 
  end
end
