class LeavesController < ApplicationController
      layout "payroll", :except => [:show]
  # GET /leaves
  # GET /leaves.xml
  def index
    @menu = 'Self Service'
    @page_name = 'Leave Card'
    @user = @current_user
    @leaves = LeaveCard.current_leave_card @current_user.id
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @leaves }
    end
  end

  # GET /leaves/1
  # GET /leaves/1.xml
  def show
    @menu = 'Organisation Settings'
    @page_name = 'View Leave Type'
    @leave = Leave.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @leave }
    end
  end

  

  # GET /leaves/1/edit
  def edit
    @menu = 'Organisation Settings'
    @page_name = 'Edit Leave Type'
    @users = User.users_in_company(session[:current_user_id])
    @leave = Leave.find(params[:id])
  end

  # POST /leaves
  # POST /leaves.xml
  def create
    @leave = Leave.new(params[:leave])
    @leave.user_id = session[:current_user_id]
    respond_to do |format|
      if @leave.save
         @leaves = Leave.all
         @leave = Leave.new
        format.html { redirect_to leaves_path }
        format.xml  { render :xml => @leave, :status => :created, :location => @leave }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @leave.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leaves/1
  # PUT /leaves/1.xml
  def update
    @leave = Leave.find(params[:id])

    respond_to do |format|
      if @leave.update_attributes(params[:leave])
        format.html { redirect_to(@leave, :notice => 'Leave has been successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @leave.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leaves/1
  # DELETE /leaves/1.xml
  def destroy
    @leave = Leave.find(params[:id])
    @leave.destroy

    respond_to do |format|
      format.html { redirect_to(leaves_url, :notice => "Leave  has been successfully deleted ") }
      format.xml  { head :ok }
    end
  end
end
