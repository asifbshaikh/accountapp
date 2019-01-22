class DesignationsController < ApplicationController
 # before_filter :menu_title
  # layout "payroll"#, :except => [:show]
  # GET /jobs
  # GET /jobs.xml
  def index
    @users = @company.users
    @search = @company.designations.search(params[:search])
    @designations = @search.page(params[:page]).per(20)
    # @designation = Designation.new

    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @designations }
    end
  end

  # GET /Designations/1
  # GET /Designations/1.xml
  def show
    @designation = Designation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @designation }
    end
  end

  #GET / Designations/new
  def new
    @designation = Designation.new

    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @designations }
    end
  end

  # GET /Designations/1/edit
  def edit
    @user = @company.users
    @designation = Designation.find(params[:id])
  end

  # POST /Designations
  # POST /Designations.xml
  def create
    @designation = Designation.new(params[:designation])
    @designation.company_id = @company.id
    @designations = @company.designations
    @designation.save
    render "create_designation"
    # respond_to do |format|
    #   if @designation.save
    #      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    #      " new designation with title #{@designation.title} in #{@company.name}", "created", @current_user.branch_id)
    #     @designations = Designation.all
    #     @designation = Designation.new
    #     flash[:success] = "Designation successfully created."
    #     format.html { redirect_to settings_payroll_path }
    #     format.xml  { render :xml => @designation, :status => :created, :location => @designation }
    #   else
    #     @users = @company.users
    #     @search = @company.designations.search(params[:search])
    #     @designations = @search.all
    #     format.html { redirect_to settings_payroll_path }
    #     format.xml  { render :xml => @designation.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /Designations/1
  # PUT /Designations/1.xml
  def update
    @designation = Designation.find(params[:id])

    respond_to do |format|
      if @designation.update_attributes(params[:designation])
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " designation with title #{@designation.title} in #{@company.name}", "updated", @current_user.branch_id)
        format.html { redirect_to(@designation, :notice => 'Designation was successfully updated.') }
        # format.xml { head :ok }
        format.json {head :ok}
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @designation.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@designation) }
      end
    end
  end

  # DELETE /Designations/1
  # DELETE /Designations/1.xml
  def destroy
    @designation = Designation.find(params[:id])
    @users = User.where(:designation_id => @designation.id)
    if @users.blank?
    @designation.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " designation #{@designation.title} in #{@company.name} is marked as deleted", "deleted", @current_user.branch_id)
      flash[:success] = "Designation deleted successfully"
      redirect_to settings_payroll_path
    else
      flash[:error] = "There are users still relating to #{@designation.title}. This designation can not be deleted."
      redirect_to :back
    end 
  end
  private
  def menu_title
      @menu = 'Organisation Settings'
    @page_name = 'Manage Designation Title'
  
  end
end
