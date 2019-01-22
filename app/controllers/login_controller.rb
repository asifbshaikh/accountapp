class LoginController < ApplicationController
  require 'active_support/secure_random'
  require 'mixpanel-ruby'

  layout 'login'
  #to skip checking the authentication and authorization.
  skip_before_filter :company_from_subdomain, :user_from_session, :only => [:index, :authenticate, :forgot_pass, :check_password, :session_timeout]
  skip_before_filter :authorize_action, :authenticate, :current_financial_year, :check_messages, :check_if_allow, :mix_panel_track
  skip_before_filter :company_active?
  skip_before_filter :check_active_session?, :only => :index
  skip_after_filter  :intercom_rails_auto_include
  skip_before_filter :verify_authenticity_token, :only => [:check_password]

  def index
  end

  def forgot_pass
  end

  def switch_company
    company = Company.find(params[:id])
    redirect_to(:subdomain => company.subdomain, :controller => :dashboard)
  end

  def check_password
   if simple_captcha_valid?
      if params[:forgot] == 'password' && params[:email].present? && params[:username].present?
        # @user = User.find_by_username_and_email(params[:username], params[:email])
        @user=User.where("username=BINARY ? and email=?", params[:username], params[:email]).first
        @company = Company.find(@user.company_id) unless @user.blank?
        if  @user && @company
           random_string = ActiveSupport::SecureRandom.hex(3)
           @user.update_attributes(:password => random_string, :reset_password => true)
           Email.reset_password(@user, random_string).deliver
           redirect_to("/login/index", :notice => "New password has been sent to your email")
        else
          flash[:error]= "Please enter valid username/email"
          redirect_to("/login/forgot_pass?email=#{params[:email]}&username=#{params[:username]}&forgot=#{params[:forgot]}")
        end
      else params[:forgot] == 'username' && !params[:email].blank? && !params[:company_name].blank?
        @company = Company.find_by_name(params[:company_name])
        @user = @company.users.find_by_email(params[:email]) unless @company.blank?
        if @user && @company && (params[:company_name]== @company.name)
          Email.got_username(@user).deliver
          redirect_to("/login/index", :notice => "Username has been sent to your email")
        else
          flash[:error]= "Please enter valid email/company name"
          redirect_to("/login/forgot_pass?email=#{params[:email]}&company_name=#{params[:company_name]}&username=#{params[:username]}&forgot=#{params[:forgot]}")
        end
      end
   else
     flash[:error] = "Please enter required details"
     redirect_to("/login/forgot_pass")
   end
  end

  def authenticate
    if request.post?
      user = User.authenticate(params[:username], params[:password])
      if user && user.active? && user.reset_password == false
        #[FIXME] The method call should be on company.
        user.login_count ||= 0
        #@progress = AccountHead.setup_progress(user.company)
        if Subscription.active?(user.company_id)
          session[:current_user_id]=user.id
          session[:company_id] = user.company_id
          session[:name]= user.first_name
          session[:last_login_at] = user.last_login_time
          session[:plan] = user.company.plan.name
          user.remote_ip = request.remote_ip
          if !user.company.plan.free_plan? && !user.company.active?
            if user.owner?
              user.update_attribute(:last_login_time, Time.zone.now)
              set_financial_year(user.company)
              if user.owner? && user.company.basic_details_required?
                #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard, :action=> :setup)
                redirect_to(:controller => :dashboard, :action=> :setup)
              else
                flash[:error] = "Your subscription has been deactivated, renew your subscription to activate again.".html_safe
                #redirect_to(:subdomain => user.company.subdomain, :controller => :billing)
                redirect_to(:controller => :billing)
              end
            else
              flash[:error] = "Your subscription has been deactivated please contact your admin.".html_safe
              redirect_to("/login/index")
            end
          else
            if user.owner? && user.company.basic_details_required?
              #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard, :action=> :setup)
              redirect_to(:controller => :dashboard, :action=> :setup)
            else
              if user.owner? && user.login_count >= 10 && user.company.secondary_details_required?
                #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard, :action=> :final_setup)
                redirect_to(:controller => :dashboard, :action=> :final_setup)
              else
                #redirect_to(:subdomain => user.company.subdomain, :controller => :dashboard)
                redirect_to(:controller => :dashboard)
              end
            end
            user.update_attribute(:last_login_time, Time.zone.now)
            set_financial_year(user.company)

      #Added this to append the login count in login_count column name in users table
      #Author: Ashish Wadekar
      #Date: 2nd November 2016

      current_login_count = user.login_count.to_i
      user.update_attribute(:login_count, current_login_count += 1)
          end
        elsif Subscription.suspended?(user.company_id)
          flash[:error] = "Your services have been suspended temporarily.".html_safe
          redirect_to("/login/index")
        else
           link = "<a href= '/login/resend_verification_email?user_id=#{user.id}&company_id=#{user.company_id}&plan_id=#{user.company.plan.id}'>Click</a>"
          flash[:error] = "Your email is not verified. Please check your inbox. <br/> #{link} here to resend verification email.".html_safe
          redirect_to("/login/index")
        end
      elsif user && user.active? && user.reset_password == true
        session[:current_user_id] = user.id
        session[:company_id] = user.company_id
        session[:plan] = user.company.plan.name
        set_financial_year(user.company)
        # redirect_to("/users/change_password?id=#{user.id}")
        #redirect_to(:subdomain => user.company.subdomain, :controller => :users, :action=>'change_password', :id=> user.id)
        redirect_to(:controller => :users, :action=>'change_password', :id=> user.id)
      else
        flash.now[:error] = "Username or Password is incorrect."
      end
    end
  end

  def email_verify
    if Subscription.update_status(params[:id], params[:token])
      redirect_to("/login/index", :notice => "Thanks, your email has been successfully verified.")
    else
      render :inline => "<p>Your email has not been verified yet. Please verify your email by clicking on the link we have sent to you.</p>"
    end
  end

  def resend_verification_email
    user = User.find(params[:user_id])
    if subscription = Subscription.find_by_company_id_and_plan_id(user.company_id, user.company.plan.id)
      Email.verify_email(user, subscription).deliver
      redirect_to ("/login/index")
      flash[:success] = 'Verification email has been resend successfully, please check your inbox.'
    else
      flash[:error]= "Something went wrong."
    end
  end

  #Added the user login count to show different modal dialogues to users to collect feedback.
  #On 1st logout of user, he will be asked to submit his feedback about the service.
  #For a paid user, on 10th logout, the user will be asked to fill in info about his business like
  #Industry, Number of employees, Annual Turnover and Business type.
  #Author: Ashish Wadekar
  #Date: 3rd November 2016
  def signout
    #Made changes to show feedback form at certain intervals as per discussion & also signout auditors gracefully
    #Author: Ashish Wadekar
    #Date: 16th February 2017
    if @current_user.auditor?
      logout_user
    elsif @current_user.login_count < 6 || @current_user.login_count % 50 == 0
      redirect_to login_logout_feedback_path
    else
      logout_user
    end
  end

  #Made changes to signout auditors gracefully
  #Author: Ashish Wadekar
  #Date: 16th February 2017
  def logout_user
    session[:current_user_id] = nil
    session[:current_auditor_id] = nil
    session[:company_id] = nil
    session[:name] = nil
    session[:last_login_at] = nil
    session[:plan] = nil
    reset_session
    redirect_to "http://www.profitbooks.net/logout"
  end

  def logout_feedback
  end

  def feedback_update
    if !params[:feedback].blank?
      @current_user.feedback = params[:feedback]
      @current_user.feedback_comment = params[:comment] unless params[:comment].blank?
      @current_user.update_attributes(:feedback => params[:feedback], :feedback_comment => params[:comment])
      Email.customer_demo_request(@current_user, @company, params[:comment]).deliver if params[:feedback].to_i == 3
      flash[:success] = "Thanks for providing feedback. It's valuable for us!"
      session[:current_user_id] = nil
      session[:current_auditor_id] = nil
      session[:name] = nil
      session[:last_login_at] = nil
      session[:plan] = nil
      reset_session
      redirect_to "http://www.profitbooks.net/logout"
    else
      flash[:error] = "Please select an option before submitting the feedback."
      redirect_to login_logout_feedback_path
    end
  end

  def session_timeout
    session[:current_user_id] = nil
    session[:current_auditor_id] = nil
    session[:name]= nil
    session[:last_login_at] = nil
    session[:plan] = nil
    reset_session
    flash[:notice] = "You have been logged out due to inactivity. Please login again."
    redirect_to "/login/index"
  end

  def convert
    company = @company
    if company.convert_to_free_plan(request.remote_ip)
      session[:plan] = company.plan.name
      Email.plan_converted_to_free(company.users.first, company).deliver
      redirect_to "/dashboard/index"
    else
      flash.now[:error] = "Sorry, plan is not converted"
      redirect_to :back
    end
  end

private

  def set_financial_year(company)
    f_year = company.financial_years.last
    temp_year = Date.today.strftime("%y")
    if f_year.start_date.month == 1
       temp_year = f_year.start_date.strftime("%y")
    elsif Time.zone.now.month >= f_year.start_date.month
        temp_year = temp_year.to_i + 1
    else
        temp_year = temp_year.to_i
    end
    session[:financial_year] = "FY"+ temp_year.to_s
  end

  # def create_mix_panel_user(user)
  #   # create or update a profile with First Name, Last Name,
  #   # E-Mail Address
  #   tracker = Mixpanel::Tracker.new('ae362b731df648a210bf492757811714')
  #   tracker.people.set_once(user.id.to_s, {
  #       'username' => user.username,
  #       'first_name'       => user.first_name,
  #       'last_name'        => user.last_name,
  #       'email'            => user.email,
  #       'company'          => user.company.name,
  #       'plan'             => user.company.plan.name,
  #   }, ip=request.remote_ip);
  # end

end
