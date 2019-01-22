class MasterObjectivesController < ApplicationController

  layout "payroll"#, :except => [:show]
  # GET /master_objectives
  # GET /master_objectives.xml
  def index
    @menu = 'Performance Management'
    @page_name = 'Master Objectives'
    @users = @company.users
    @search = @company.master_objectives.search(params[:search])
    @master_objectives = @search.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @master_objectives }
    end
  end

  # GET /master_objectives/1
  # GET /master_objectives/1.xml
  def show
    @menu = 'Performance Management'
    @page_name = 'View Master Objective'
    @master_objective = MasterObjective.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @master_objective }
    end
  end

  # GET /master_objectives/new
  # GET /master_objectives/new.xml
  def new
    @menu = 'Performance Management'
    @page_name = 'Create Master Objective'
    @users = @company.users
    @master_objective = MasterObjective.new
    @departments = @company.departments
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @master_objective }
    end
  end

  # GET /master_objectives/1/edit
  def edit
    @menu = 'Performance Management'
    @page_name = 'Edit Master Objective'
    @users = @company.users
    @master_objective = MasterObjective.find(params[:id])
    @departments = @company.departments
  end

  # POST /master_objectives
  # POST /master_objectives.xml
  def create
    @master_objective = MasterObjective.new(params[:master_objective])
    @master_objective.company_id = @company.id
    @master_objective.created_by = @current_user.id
    respond_to do |format|
      if @master_objective.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " new master objective '#{@master_objective.objective_name}' for #{@master_objective.department_name} department", "created", @current_user.branch_id)
        flash[:success]= "Master objective successfully created."
        format.html { redirect_to(@master_objective) }
        format.xml  { render :xml => @master_objective, :status => :created, :location => @master_objective }
      else
        @menu = 'Performance Management'
        @page_name = 'Create Master Objective'
        @users = @company.users
        @departments = @company.departments
        format.html { render :action => "new" }
        format.xml  { render :xml => @master_objective.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /master_objectives/1
  # PUT /master_objectives/1.xml
  def update
    @master_objective = MasterObjective.find(params[:id])

    respond_to do |format|
      if @master_objective.update_attributes(params[:master_objective])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " master objective '#{@master_objective.objective_name}' for #{@master_objective.department_name} department", "updated", @current_user.branch_id) 
        format.html { redirect_to(@master_objective, :notice => 'Master objective was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Performance Management'
        @page_name = 'Edit Master Objective'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @master_objective.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /master_objectives/1
  # DELETE /master_objectives/1.xml
  def destroy
    @master_objective = MasterObjective.find(params[:id])
    @master_objective.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    "  master objective '#{@master_objective.objective_name}' for #{@master_objective.department_name} department 
    is marked as deleted","deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(master_objectives_url) }
      format.xml  { head :ok }
    end
  end
end
