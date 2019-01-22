class ProjectsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # before_filter :menu_title
  # GET /projects
  # GET /projects.xml
  def index
   @project = Project.new
   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
      format.json { render :json => ProjectDatatable.new(view_context, @company, @current_user)}
    end
  end

 # def ongoing_project
 #    @projects = @company.projects.where(:status => false).page(params[:page]).per(20)
 # end

 # def completed_project
 #    @projects = @company.projects.where(:status => true).page(params[:page]).per(20)
 # end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = @company.projects.find(params[:id])
    # @invoices = @project.invoices.where(:deleted => false).page(params[:page]).per(10)
    # @expenses = @project.expenses.where(:deleted => false).page(params[:page]).per(10)
    # @receipt_vouchers = @project.receipt_vouchers.where(:deleted => false).page(params[:page]).per(10)
    # @purchases = @project.purchases.where(:deleted => false).page(params[:page]).per(10)
    # @tasks = @project.tasks.page(params[:page]).per(10)
    # @projects = @company.projects.where(:status => false)
    @task = Task.new
    if params[:voucher]== 'invoice'
      @vouchers = @invoices
    elsif params[:voucher]== 'expense'
      @vouchers = @expenses
    elsif params[:voucher]=='receipt'
      @vouchers = @receipt_vouchers
    elsif params[:voucher]== 'purchase'
      @vouchers = @purchases
    elsif params[:voucher]=='task'
      @vouchers = @tasks
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = @company.projects.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.create_project(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @project.save
       @project.register_user_action(request.remote_ip, 'created', @current_user)
       format.js {render "/tasks/add_project"}
       format.html { redirect_to(projects_path, :notice => 'Project was successfully created.') }
       format.xml  { render :xml => @project, :status => :created, :location => @project }
     else
      @projects = @company.projects
      format.js {render "/tasks/add_project"}
      format.html { render :action => "index" }
      format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
    end
  end
end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.update_project(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @project.update_attributes(params[:project])
        @project.register_user_action(request.remote_ip, 'updated', @current_user)
        format.html { redirect_to(projects_path, :notice => 'Project was successfully updated.') }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
        format.json{ respond_with_bip(@project)}
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = @company.projects.find(params[:id])
    @invoices = @project.invoices.where(:deleted => false)
    @expenses = @project.expenses.where(:deleted => false)
    @receipt_vouchers = @project.receipt_vouchers.where(:deleted => false)
    @purchases = @project.purchases.where(:deleted => false)
    @tasks = @project.tasks
    if @invoices.blank? && @expenses.blank? && @receipt_vouchers.blank? && @purchases.blank? && @tasks.blank?
     @project.destroy
     @project.register_user_action(request.remote_ip, 'deleted', @current_user)
     flash[:success] = "Project deleted successfully"
   else
    flash[:error] = "Project can not be, still some vouchers created under this project"
  end
  respond_to do |format|
    format.html { redirect_to(projects_url) }
    format.xml  { head :ok }
  end
end

  #action to mark a project complete
  def mark_complete
    @project = @company.projects.find(params[:id])
    respond_to do |format|
      if @project.complete_project(@current_user)
       #@project.register_user_action(request.remote_ip, 'completed', @current_user)
       format.html { redirect_to(@project, :notice => "Project has been completed successfully") }
       format.xml  { head :ok }
     else
       @projects = @company.projects.page(params[:page]).per(20)
       flash[:error] = "The project  was not deleted due to an error."
       format.html { render :action => "index" }
       format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
     end
   end
 end

 private
 def record_not_found
  flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
  redirect_to :controller=>:tasks, :action=> :index
end
end
