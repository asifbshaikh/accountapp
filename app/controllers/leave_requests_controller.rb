class LeaveRequestsController < ApplicationController
  # before_filter :menu_title
  # layout "payroll" #, :except => [:show]

  # GET /leave_requests
  # GET /leave_requests.xml
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  respond_to :html, :json

  def dashboard
    @leave_cards = @current_user.leave_cards.where(:card_year => Time.zone.now.year)
    @leave_requests = LeaveRequest.last_five_pending_approvals @current_user.id
    @approval_requests = LeaveRequest.last_five_pending_for_approval_by_user @current_user
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end
  end

  def index
    # @leave_requests = LeaveRequest.pending_approval @current_user.id

    #Added by Rohit for leave request 0n 16th Aug,2016
    ######################################################
    @user = User.find_by_id_and_company_id(@current_user.id, @company.id)
    @leave_request = LeaveRequest.new_leave_request(params, @user, @company)
    @approvers = User.all_remaining_users @user
    @approval_requests = LeaveRequest.where("company_id = ? and leave_status=0", @company.id)
    @approved_leave_requests = LeaveRequest.where("company_id = ? and leave_status=1", @company.id)
    @rejected_leave_requests = LeaveRequest.where("company_id = ? and leave_status=2", @company.id)
    @leave_cards = LeaveCard.current_leave_card @user.id
      
      

    #######################################################


    @users = @company.users
    @leave_requests = @company.leave_requests.where(:leave_status => "0").page(params[:page]).per(20)
    @leave_cards = @company.leave_cards.page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end
  end

  def approved
    @leave_requests = LeaveRequest.approved @current_user.id
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end
  end

  def rejected
    @leave_requests = LeaveRequest.rejected @current_user.id
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end
  end

  def revoke
    @leave_request = LeaveRequest.find_by_id(params[:id])
    @leave_request.revoke
    @approved_leave_requests = LeaveRequest.approved @current_user.id
    respond_to do |format|
      format.js
    end
  end

  def my_leave_request
     @leave_requests = LeaveRequest.find_all_by_user_id(@current_user.id, :order => 'created_at DESC').page(params[:page]).per(20)
   end

  # GET /leave_requests/1
  # GET /leave_requests/1.xml
  def show
    @leave_request = LeaveRequest.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @leave_request }
    end
  end

  # GET /leave_requests/new
  # GET /leave_requests/new.xml
  def new
    @leave_cards = LeaveCard.where(:company_id => @company.id ,:user_id => @current_user.id, :card_year => Time.zone.now.year)
    @leave_request = LeaveRequest.new
    @approvers = User.all_remaining_users @current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @leave_request }
    end
  end


  # GET /leave_requests/1/edit
  def edit
    @approvers = User.all_remaining_users @current_user
    @leave_request = LeaveRequest.find(params[:id])
    @leave_cards = LeaveCard.where(:company_id => @company.id ,:user_id => @current_user.id, :card_year => Time.zone.now.year)
  end

  # POST /leave_requests
  # POST /leave_requests.xml
  def create
    @leave_request = LeaveRequest.new_leave_request(params, @current_user, @company)
    respond_to do |format|
      if @leave_request.save
        Email.leave_request_created(@current_user, @company, @leave_request).deliver
         @leave_request.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to("/myprofile/#{@current_user.id}", :notice => 'Leave request created and an email about this has been sent successfully ') }
        format.xml  { render :xml => @leave_request, :status => :created, :location => @leave_request }
      else
         @users = @company.users
         @approvers = User.all_remaining_users @current_user
         @leave_cards = LeaveCard.where(:company_id => @company.id ,:user_id => @current_user.id, :card_year => Time.zone.now.year)

        format.html { redirect_to "/myprofile/#{@current_user.id}" }
        format.xml  { render :xml => @leave_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leave_requests/1
  # PUT /leave_requests/1.xml
  def update
    @leave_request = LeaveRequest.find(params[:id])
    @leave_types = @company.leave_types
    @leave_cards = LeaveCard.where(:company_id => @company.id ,:user_id => @current_user.id, :card_year => Time.zone.now.year)
    respond_to do |format|
      if @leave_request.update_attributes(params[:leave_request])
         @leave_request.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to(@leave_request, :notice => 'Leave request was successfully updated.') }
        format.xml  { head :ok }
      else
          @leave_types = @company.leave_types
        @leave_cards = LeaveCard.where(:company_id => @company.id ,:user_id => @current_user.id, :card_year => Time.zone.now.year)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @leave_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leave_requests/1
  # DELETE /leave_requests/1.xml
  def destroy
    @leave_request = LeaveRequest.find(params[:id])
    @leave_request.destroy
    @leave_request.register_user_action(request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to "/users/leave_detail?id=#{@current_user.id}/#leaves" }
      format.xml  { head :ok }
    end
  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
end
