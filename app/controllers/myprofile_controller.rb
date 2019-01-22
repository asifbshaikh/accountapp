class MyprofileController < ApplicationController

	 require 'active_support/secure_random'
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /users
  # GET /users.xml
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    if @current_user.can_view?(@user)
      @user_salary_detail = @user.user_salary_detail
      @users_salary = @user.salaries.order("month DESC")
      #@user_information = @user.user_information
      @department = @user.department
      @designation = @user.designation
      #@user_assets = CompanyAsset.where(:assigned_to => @user.id).page(params[:page]).per(20)
      @salary_structure = SalaryStructure.current_salary_structure(@company.id, @user.id, nil)
      @salary_structure_histories = SalaryStructureHistory.where(:company_id=> @company.id,:for_employee => @user.id)
      @usernotes = Usernote.where(:user_id => @user.id)
      @leave_cards = LeaveCard.current_leave_card @user.id
      @pending_leave_requests = LeaveRequest.pending_approval @user.id
      @all_requests= LeaveRequest.all_requests @user.id
      @approved_leave_requests = LeaveRequest.approved @user.id
      @rejected_leave_requests = LeaveRequest.rejected @user.id
      @approval_requests = LeaveRequest.pending_for_approval_by_user @user
      @leave_request = LeaveRequest.new_leave_request(params, @user, @company)
      @approvers = User.all_owner_and_hr @user
      @payheads = @company.payheads.where(:optional => false).order("created_at DESC")

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    else
      flash[:error] = 'You have been redirected to Dashboard as you are not authorized to access this function.'
      redirect_to controller: :dashboard, action: :index
    end  
  end

  def leave_detail
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    @department = @user.department
    @designation = @user.designation
    @user_assets = CompanyAsset.where(:assigned_to => @user.id).page(params[:page]).per(20)
    @salary_structure = SalaryStructure.current_salary_structure(@company.id, @user.id, nil)
    @salary_structure_histories = SalaryStructureHistory.where(:company_id=> @company.id,:for_employee => @user.id)
    @usernotes = Usernote.where(:user_id => @user.id)
    @leave_cards = LeaveCard.current_leave_card @user.id
    @pendig_leave_requests = LeaveRequest.pending_approval @user.id
    @approved_leave_requests = LeaveRequest.approved @user.id
    @rejected_leave_requests = LeaveRequest.rejected @user.id
    @pending_leave_requests = LeaveRequest.pending_approval @user.id
    @approval_requests = LeaveRequest.pending_for_approval_by_user @user
    @leave_request = LeaveRequest.new_leave_request(params, @user, @company)
    @approvers = User.all_remaining_users @user
    @payheads = @company.payheads.where(:optional => false).order("created_at DESC")
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
 def salary_details
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    @department = @user.department
    @designation = @user.designation
    @user_assets = CompanyAsset.where(:assigned_to => @user.id).page(params[:page]).per(20)
    @salary_structure = SalaryStructure.current_salary_structure(@company.id, @user.id, nil)
    @salary_structure_histories = SalaryStructureHistory.where(:company_id=> @company.id,:for_employee => @user.id)
    @usernotes = Usernote.where(:user_id => @user.id)
    @leave_cards = LeaveCard.current_leave_card @user.id
    @pending_leave_requests = LeaveRequest.pending_approval @user.id
    @approved_leave_requests = LeaveRequest.approved @user.id
    @rejected_leave_requests = LeaveRequest.rejected @user.id
    @approval_requests = LeaveRequest.pending_for_approval_by_user @user
    @leave_request = LeaveRequest.new_leave_request(params, @user, @company)
    @approvers = User.all_remaining_users @user
    @payheads = @company.payheads.where(:optional => false).order("created_at DESC")
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def personal_info
    @user = User.find_by_id_and_company_id(params[:id], @company.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def work_info
    @user = User.find_by_id_and_company_id(params[:id], @company.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def user_assets
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    @user_assets = CompanyAsset.where(:assigned_to => @user.id).page(params[:page]).per(20)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def change_password
    @user = User.find_by_id(params[:id])
    respond_to do |format|
      if params[:user_id].blank?
        format.html { render :layout => false }# show.html.erb
        format.xml  { render :xml => @user }
      else
        format.html { render 'renew_password' }
      end
    end
  end

  def pass_update
    @current_user = User.find(session[:current_user_id])
    user = User.authenticate(@current_user.username, params[:old_pass])
    if (user == @current_user) && !params[:new_pass].blank? && !params[:confirm_pass].blank?
       # @progress = AccountHead.setup_progress(user.company.id)
      if params[:new_pass] == params[:confirm_pass]
        if Subscription.active?(user.company_id)
          password = params[:new_pass]
          session[:name]= user.first_name
          session[:last_login_at] = user.last_login_time
          user.update_attribute(:password, password)
          #user.update_attribute(:reset_password, false)
          # if user.roles[0].name == "Employee"
          #   redirect_to(:subdomain => user.company.subdomain, :controller => :payroll_dashboard)
          # elsif @progress < 50
          #   redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard, :action => :setup)
          # else
          # end
          flash[:success] = "Password has been changed successfully"
          #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard)
          #redirect_to(:subdomain => user.company.subdomain, :controller => :login)
          redirect_to(:controller => :login)
        elsif Subscription.suspended?(user.company_id)
          flash[:error] = "Your services have been suspended temporarily.".html_safe
          redirect_to("/login/index")
        end
      else
        redirect_to '/myprfile/change_password', :notice => 'Confirm password does not match'
      end
    else
      redirect_to '/myprofile/change_password', :notice => 'Invalid password'
    end
  end

 def reset_password

 end

 def set_new_password
    @current_user = User.find(session[:current_user_id])
    user = User.authenticate(@current_user.username, params[:old_pass])
    if (user == @current_user) && !params[:new_pass].blank? && !params[:confirm_pass].blank?
      if params[:new_pass] == params[:confirm_pass]
          password = params[:new_pass]
          session[:name]= user.first_name
          user.update_attributes(:password => password, :reset_password => false)
          # redirect_to :back
          flash[:success] = "Password has been changed successfully"
      else
        # redirect_to '/users/reset_password'
         flash[:error] = 'Confirm password does not match'
      end
    else
      # redirect_to '/users/reset_password'
      flash[:error] = 'Invalid password'
    end
 end

  def my_profile
    @current_user = User.find(params[:id])
    @user = !params[:id].nil? ? User.find(params[:id]) : @current_user
    # @usernote = Usernote.find(@user.usernote)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  

 
  def edit_avatar
    data_avatar = nil
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
  end
  def update_avtar
    @is_save = false
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    if @user.update_attribute(params[:user])
    @is_save = true
    else
    @is_save= false
   end
  end

end
