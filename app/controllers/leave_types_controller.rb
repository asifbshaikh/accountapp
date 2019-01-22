class LeaveTypesController < ApplicationController
  # before_filter :menu_title
  # layout "payroll"#, :except => [:show]

  # GET /leaves
  # GET /leaves.xml
  def index
    @users = @company.users
    @search = @company.leave_types.search(params[:search])
    @leave_types = @search.page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_types }
    end
  end

  # GET /leaves/1
  # GET /leaves/1.xml
  def show
    @leave_type = LeaveType.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @leave_type }
    end
  end

  # GET /leaves/1/edit
  def edit
    @users = @company.users
    @leave_type = LeaveType.find(params[:id])
  end

  #POST / leaves/new
  def new
    @leave_type = LeaveType.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @leave_types }
    end
  end

  # POST /leaves
  # POST /leaves.xml
  def create
    @leave_type = LeaveType.create_leave_type(params, @company, @current_user)
    @leave_types = @company.leave_types
    respond_to do |format|
      if @leave_type.valid?  
        @leave_type.save_with_leave_card(@company)
        @leave_type.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
      end
      format.js {render "create_leave_type"}
    end
  end

  # PUT /leaves/1
  # PUT /leaves/1.xml
  def update
    @leave_type = LeaveType.find(params[:id])
    respond_to do |format|
      if  @leave_type.update_attributes(params[:leave_type])
        @leave_type.register_user_action(request.remote_ip, 'updated',@current_user.branch_id)
        format.html { redirect_to(@leave_type, :notice => 'Leave Type was successfully updated.') }
        # format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @leave_type.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@leave_type) }
      end
    end
  end

  # DELETE /leaves/1
  # DELETE /leaves/1.xml
  def destroy
    @leave_type = LeaveType.find(params[:id])
    @leave_requests = LeaveRequest.where(:leave_type_id => @leave_type.id) 
    if @leave_requests.blank? 
     @leave_type.destroy
     @leave_type.register_user_action(request.remote_ip, 'deleted', @current_user.branch_id)
    else
      flash[:error] = "You have #{@leave_requests.count} leave request created for this leave type, please delete leave request before deleting this leave type." 
    end
    respond_to do |format|
      format.html { redirect_to(settings_payroll_path) }
      format.xml  { head :ok }
    end
  end
private
 def menu_title
   @menu = "Organisation Settings"
   @page_name = "Manage Leave Type"
 end
end 
