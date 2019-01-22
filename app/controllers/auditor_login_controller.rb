class AuditorLoginController < ApplicationController

  require 'active_support/secure_random'
  layout 'auditor'

  skip_before_filter :company_from_subdomain, :authenticate, :user_from_session, :only => [:index, :authenticate, :switch, :check_password, :accept_request, :client_invitation_page]
  skip_before_filter :authorize_action,  :check_messages, :check_if_allow, :current_financial_year, :mix_panel_track
  skip_before_filter :company_active?
  skip_before_filter :check_active_session?, :only => :index
  skip_after_filter  :intercom_rails_auto_include
  skip_before_filter :verify_authenticity_token, :only => [:check_password]

  def index
  end

  def forgot_pass
  end

  def check_password
    if simple_captcha_valid?
      if !params[:username].blank?
        @auditor = Auditor.find_by_username(params[:username])
        if !@auditor.blank?
          #random_string = SecureRandom.hex(3)
          #if @auditor.update_attributes(:password => random_string, :reset_password => true)
            new_password = @auditor.new_password
            Email.auditor_reset_password(@auditor, new_password).deliver
            redirect_to("/login/index#auditor", :notice => "New password has been sent to your email")
          #end
        else
          flash[:error] = "Please enter required details"
          redirect_to("/auditor_login/forgot_pass")
        end
      else
        flash[:error] = "Please enter required details"
        redirect_to("/auditor_login/forgot_pass")
      end
    else
      flash[:error] = "Please enter required details"
      redirect_to("/auditor_login/forgot_pass")
    end
  end


  def authenticate
    if request.post?
      auditor = Auditor.authenticate(params[:username], params[:password])
      if auditor && !auditor.reset_password?
        session[:current_auditor_id]= auditor.id
        redirect_to '/auditor_login/switch'
      elsif auditor && auditor.reset_password?
        session[:current_auditor_id] = auditor.id
        redirect_to(:controller => :auditors, :action=>'change_password', :id=> auditor.id)
      else
        flash[:error] = "Invalid username/password combination"
        redirect_to '/login/index#auditor'
      end
    end
  end

  def proceed_request
    invitation_detail = InvitationDetail.find_by_token(params[:token])
    auditor = Auditor.find_by_username invitation_detail.email unless invitation_detail.blank?
    if invitation_detail.blank?
      render :inline =>"<p>Invalid auditor request<p>"
    elsif invitation_detail.status_id == 1
      redirect_to "/auditor_login/index#auditor"
      flash.now[:notice] = "You are already accept this request."
    elsif !auditor.blank?
      redirect_to "/auditor_login/accept_request?token=#{invitation_detail.token}"
    elsif invitation_detail
      redirect_to "/auditors/new?token=#{invitation_detail.token}"
    else

    end
  end

  def accept_request
    @invitation_detail = InvitationDetail.find_by_token(params[:token])
    @company = Company.find @invitation_detail.company_id
    if request.method == 'POST'
      auditor = Auditor.authenticate(@invitation_detail.email, params[:password])
      if auditor && CompanyAuditor.accept_request(@invitation_detail.id, auditor.id)
        Email.request_accepted(@company.users.first, @invitation_detail).deliver
        check_subscription(auditor)
      else
        flash.now[:error] = 'Invalid password'
      end
    end
  end

  def decline_request
    @invitation_detail = InvitationDetail.find_by_token(params[:token])
    @company = Company.find @invitation_detail.company_id unless @invitation_detail.blank?
    if !@invitation_detail.blank?
      @invitation_detail.decline
      Email.request_declined(@company.users.first, @invitation_detail).deliver
      redirect_to :back
      flash[:success] = "Request was declined"
    else
      redirect_to :back
      flash[:error] = "Invalid request"
    end
  end

  def switch
   if request.method == 'POST'
     auditor = Auditor.find session[:current_auditor_id]
     check_subscription(auditor)
   else
     @auditor = Auditor.find session[:current_auditor_id]
     @companies = @auditor.companies
   end
  end

  def check_subscription(auditor)
    company = Company.find params[:company_id]
    if Subscription.active?(company.id)
      session[:current_auditor_id]= auditor.id
      session[:plan] = company.plan.name
      session[:company_id] = company.id
      temp_year = Date.today.strftime("%y")
      if Date.today.month > 3
      	temp_year = temp_year.to_i + 1
      else
      	temp_year = temp_year.to_i
      end
      session[:financial_year] = "FY"+ temp_year.to_s
      redirect_to(:controller => :dashboard, :action => :index)
    elsif Subscription.suspended?(company.id)
      flash[:error] = "Your services have been suspended temporarily.".html_safe
      redirect_to("/auditor_login/index#auditor")
    end
  end
end
