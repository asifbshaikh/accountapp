class LeaveApprovalController < ApplicationController
  # layout 'payroll'

  def index
    @menu = 'Self Service'
    @page_name = 'Leave approval'
    @approval_requests = LeaveRequest.pending_for_approval_by_user @current_user

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end

  end

  def edit
    @leave_request = LeaveRequest.find(params[:id])
    respond_to do |format|
      format.js # index.html.erb
    end
  end

  def approve
    @approval_request = LeaveRequest.find(params[:id])
    respond_to do |format|
      if @approval_request.approve
        Email.leave_request_approved(@current_user, @company, @approval_request).deliver
        flash[:success] = "Email has been sent successfully"
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         "#{@current_user.full_name} approved leave request from #{User.find(@approval_request.user_id).full_name} starting from #{@approval_request.start_date} to #{@approval_request.end_date}", "updated",@current_user.branch_id)
        format.js
      end  
    end

  end

  def update
    @approval_request = LeaveRequest.find(params[:id])

    respond_to do |format|
      if @approval_request.update_attributes(params[:leave_request])
        Email.leave_request_rejected(@current_user, @company, @approval_request).deliver
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         "#{@current_user.full_name} rejected leave request from #{User.find(@approval_request.user_id).full_name} starting from #{@approval_request.start_date} to #{@approval_request.end_date}", "updated",@current_user.branch_id)
        format.js
      end  
    end
  end

  def reject_leave
    @leave_request = LeaveRequest.find(params[:id])
    respond_to do |format|
      if @leave_request.update_attributes(params[:leave_request])
        Email.leave_request_rejected(@current_user, @company, @leave_request).deliver
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         "#{@current_user.full_name} rejected leave request from #{User.find(@leave_request.user_id).full_name} starting from #{@leave_request.start_date} to #{@leave_request.end_date}", "updated",@current_user.branch_id)
        format.js
      end  
    end
  end
end
