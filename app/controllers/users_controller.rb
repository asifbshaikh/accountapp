class UsersController < ApplicationController
  require 'active_support/secure_random'
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  skip_before_filter :authorize_action, :current_financial_year, if: :json_request?
  # GET /users
  # GET /users.xml
  def index
    if @current_user.owner? || @current_user.hr?
      #@inactive_users = User.where(:company_id => @company.id, :deleted => true)
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
        format.json { render :json => EmployeeDatatable.new(view_context,@company,@current_user)}
      end
    else
      flash[:error] = 'You have been redirected to Dashboard as you are not authorized to access this function.'
      redirect_to controller: :dashboard, action: :index      
    end  
  end

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


  def manage_payroll
    @payroll_details = PayrollDetail.where(:company_id => @company.id)
    @current_month = Time.zone.now.month
    if @company.created_at.to_date > (Time.zone.now.to_date - 6.months)
      @start_month= @company.created_at.to_date.month>Time.zone.now.to_date.month ? (@company.created_at.month-13) : (@company.created_at.to_date.month-1)
    else
      @start_month=(@current_month-6)
    end
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
      if params[:new_pass] == params[:confirm_pass]
        if Subscription.active?(user.company_id)
          password = params[:new_pass]
          session[:name]= user.first_name
          session[:last_login_at] = user.last_login_time
          user.update_attribute(:password, password)
          flash[:success] = "Password has been changed successfully"
          current_login_count = user.login_count.to_i
          user.update_attribute(:login_count, current_login_count += 1)
          if user.owner? && user.company.basic_details_required?
            #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard, :action=> :setup)
            redirect_to(:controller => :dashboard, :action=> :setup)
          else
            #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard) #Changed redirection to dashboard to suite the new login flow 11th November 2016
            redirect_to(:controller => :dashboard) #Changed redirection to dashboard to suite the new login flow 11th November 2016
          end
        elsif Subscription.suspended?(user.company_id)
          flash[:error] = "Your services have been suspended temporarily.".html_safe
          redirect_to("/login/index")
	else
          flash[:error] = "Your account is not yet activated. Please verify your email.".html_safe
          redirect_to("/login/index")
        end
      else
        redirect_to '/users/change_password', :notice => 'Confirm password does not match'
      end
    else
      redirect_to '/users/change_password', :notice => 'Invalid password'
    end
  end

 def reset_password

 end

 def set_new_password
    @current_user = User.find(params[:user_id])
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


  def new
    @departments = @company.departments
    @designations = @company.designations
    @branches = @company.branches
    @user = User.new
    @user.build_user_information
    @user.build_user_salary_detail
    1.times{ @user.assignments.build} #do not allow multiple roles
    @user.assignments[0].role_id = @company.plan.roles.find_by_name("Staff").id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @departments = @company.departments
    @designations = @company.designations
    @branches = @company.branches
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    #This condtional checking was added as bugfix for the NoMethodError raised for user_information method when user instance is not found in a company
    #Author: Ashish Wadekar
    #Date: 17th August 2016
    if @user.nil?
      flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
      redirect_to :action=> :index
    else
      @user.build_user_information if @user.user_information.blank?
      @user.build_user_salary_detail if @user.user_salary_detail.blank?
    end
  end


  def basic_info
    user= User.find(params[:user_id])
    basic_info = user.user_information
    if basic_info.nil?
      @basic_details= UserInformation.new(params[:users])
      @basic_details.user_id=user.id
      @basic_details.save
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         "basic informatin of #{user.full_name}", "updated", @current_user.branch_id)
      flash[:success] = 'Basic information updated successfully.'
    else
      @basic_details=basic_info.update_attributes(params[:users])
       Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         "basic information of #{user.full_name}", "updated", @current_user.branch_id)
       flash[:success] = 'Basic information updated successfully.'
    end

  end

  def work_info
    user= User.find(params[:user_id])
    work_info = user.user_salary_detail
    if work_info.nil?
      @work_details= UserSalaryDetail.new(params[:users])
      @work_details.user_id=user.id
      @work_details.save
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
       "basic information of #{user.full_name}", "updated", @current_user.branch_id)
      flash[:success] = 'Work information updated successfully.'
    else
      @work_details=work_info.update_attributes(params[:users])
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
       "work information of #{user.full_name}", "updated", @current_user.branch_id)
      flash[:success] = 'Work information updated successfully.'
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    random_string = SecureRandom.hex(4)
    @user.company_id = @company.id
    @user.password = random_string
    @user.password_confirmation = random_string
    @user.reset_password = true
    respond_to do |format|
      if @user.valid?
         @user.save_with_leave_card(@company)
         @company.subscription.increment_user_count
         @user.register_user_action(request.remote_ip, "created", @current_user)
          
        format.html { redirect_to("/users/#{@user.id}") }
        format.xml  { render :xml => @user, :status => :created, :location => @user }

         Email.user_created(@user, random_string).deliver
      else
        @departments = @company.departments
        @designations = @company.designations
        @branches = @company.branches
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end


  def mail_new_user

    @user = User.where(:id=>params[:id])
    random_string = SecureRandom.hex(3)
    @user.password = random_string
    @user.password_confirmation = random_string
    @user.update

    Email.user_created(@user,random_string).deliver

  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    #@user = User.find_by_id_and_company_id(params[:id], @company.id)
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.register_user_action(request.remote_ip, "updated",@current_user)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        @departments = @company.departments
        @designations = @company.designations
        @branches = @company.branches
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    respond_to do |format|
      if @user.delete(@current_user.id)
        @company.subscription.decrease_user_count
        @user.register_user_action(request.remote_ip, "deleted", @current_user)
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
        Email.delete_user_confirmation(@user).deliver
        flash[:success]= "User deleted successfully and an email has been send to user."
      end
     end
  end

  def restore_user
    @user = User.find_by_id_and_company_id(params[:id], @company.id)
    respond_to do |format|
      if @user.restore(@current_user.id)
        @company.subscription.increment_user_count
        @user.register_user_action(request.remote_ip, "created", @current_user)
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
        Email.restore_user_confirmation(@user).deliver
        Email.activation_user_confirmation(@current_user,@user).deliver
        flash[:success]= "User restored successfully and an email has been send to user."
      end
     end
  end

  def delete_note
   @user = User.find_by_id_and_company_id(params[:id], @company.id)
   respond_to do |format|
   if Usernote.delete_usernote(params[:usernote_id], @user.id)
    format.html { redirect_to(@user, :notice => 'Usernote successfully deleted.') }
    format.xml  { head :ok }
   else
    flash[:error] = "Something went wrong"
   end
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

private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
  def should_paid
    if @company.subscription_type == true && @company.users.count >= 1
      flash[:alert] = "Please subscribe first"
      redirect_to "/dashboard/index"
    end
  end
end
