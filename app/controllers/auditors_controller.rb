class AuditorsController < ApplicationController
require 'active_support/secure_random'
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /auditors
  # GET /auditors.xml
  #layout 'login'
  skip_before_filter :authorize_action, :authenticate, :check_if_allow, :only => ['new', 'create', 'change_password','pass_update']
  skip_before_filter :current_financial_year, :company_from_subdomain, :mix_panel_track, :only => ['new', 'create', 'change_password','pass_update']
  def index
    # @menu = "Auditor"
    # @page_name = "List auditor"
     @invitation_details = @company.invitation_details.where(:status_id => [0,2])
     @auditors = @company.auditors
    @invitation_detail = InvitationDetail.new
    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @auditors }
       format.json { render :json => AuditorsDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  # GET /auditors/1
  # GET /auditors/1.xml
  def show
    @menu = "Auditor"
    @page_name ="Auditor details"
    @auditor = @company.auditors.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @auditor }
    end
  end

  # GET /auditors/new
  # GET /auditors/new.xml
  def new
  @auditor = Auditor.new
	@invitation_detail = InvitationDetail.find_by_token(params[:token])
	@auditor.username = @invitation_detail.email
    respond_to do |format|
      format.html {render :layout => 'login'}# new.html.erb
      format.xml  { render :xml => @auditor }
    end
  end

  # GET /auditors/1/edit
  def edit
	@menu ="Auditor"
	@page_name = "Edit Auditor"
    @auditor = @company.auditors.find(params[:id])
  end

  # POST /auditors
  # POST /auditors.xml
  def create
    @auditor = Auditor.new(params[:auditor])
    @company = Company.find params[:company_id]
    @auditor.reset_password = false
    #@auditor.auditor_assignments[0].role_id = @company.plan.roles.find_by_name("Auditor").id
    respond_to do |format|
      @invitation_detail = InvitationDetail.find params[:invitation_detail_id]
      if @auditor.valid? && @auditor.username == @invitation_detail.email
        if @auditor.save_with_company(@company.id, @invitation_detail.id)
          if Subscription.active?(@company.id)
          session[:current_auditor_id]=@auditor.id
          session[:plan] = @company.plan.name
          temp_year = Date.today.strftime("%y")
          if Date.today.month > 3
            temp_year = temp_year.to_i + 1
          else
            temp_year = temp_year.to_i
          end
          session[:financial_year] = "FY"+ temp_year.to_s
          #format.html { redirect_to(:subdomain => @company.subdomain, :controller => :dashboard)}
          format.html { redirect_to(:controller => :dashboard, :action => :index)}
          elsif Subscription.suspended?(@company.id)
            flash[:error] = "Your services have been suspended temporarily.".html_safe
            redirect_to("/login/index")
          end
        else
          flash.now[:error] = 'Error while processing, please try again.'
          format.html { render :action => "new" }
        end
      elsif @auditor.username != @invitation_detail.email
        flash.now[:error] = 'This is not requested auditor.'
        format.html { render :action => "new", :layout => 'login' }
      else
        format.html { render :action => "new", :layout => 'login' }
        format.xml  { render :xml => @auditor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /auditors/1
  # PUT /auditors/1.xml
  def update
    @auditor = @company.auditors.find(params[:id])

    respond_to do |format|
      if @auditor.update_attributes(params[:auditor])
        format.html { redirect_to(@auditor, :notice => 'Auditor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @auditor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /auditors/1
  # DELETE /auditors/1.xml
  def soft_delete
    @auditor = @company.auditors.find(params[:id])
    CompanyAuditor.soft_delete(@company.id, @auditor.id)
    #@auditor.delete

    respond_to do |format|
      format.html { redirect_to(auditors_url) }
      format.xml  { head :ok }
    end
  end
  def destroy
    @auditor = @company.auditors.find(params[:id])
    company_auditor = CompanyAuditor.find_by_auditor_id_and_company_id(@auditor.id, @company.id)
    company_auditor.delete
    #@auditor.delete

    respond_to do |format|
      format.html { redirect_to(auditors_url) }
      format.xml  { head :ok }
    end
  end

  def add_auditor
   invit_d = InvitationDetail.find_by_company_id_and_email_and_status_id(@company.id, params[:invitation_detail][:email], 0)
    require 'active_support/secure_random'
    @invitation_detail = InvitationDetail.new(params[:invitation_detail])
    @invitation_detail.company_id = @company.id
    @invitation_detail.sent_by = @current_user.id
    @invitation_detail.token = SecureRandom.hex(8)

  end

  def invite_auditor
    if request.method != 'POST'

    else
      auditor = Auditor.find_by_username params[:email]
      if auditor
        Email.auditor_invitation(auditor.first_name, auditor.username, @company).deliver
      else
        Email.auditor_invitation(params[:name], params[:email], @company).deliver
      end
      flash.now[:success] = 'Request have been sent successfully'
      redirect_to auditors_path
    end
  end

  def resend_invitation
    @invitation_detail = InvitationDetail.find(params[:id])
    result = false
    unless @invitation_detail.blank?
      Email.auditor_invitation(@invitation_detail).deliver
      result = true
    end
    redirect_to auditors_path
    if result
      flash[:sucess] = "Invitation has been sent successfully"
    else
      flash[:error] = "Invalid invitation"
    end
  end

def change_password
    @auditor = Auditor.find_by_id(params[:id])
    respond_to do |format|
      if params[:auditor_id].blank?
        format.html { render :layout => false }# show.html.erb
        format.xml  { render :xml => @auditor }
      else
        format.html { render 'renew_password' }
      end
    end
  end

  def pass_update
    @current_user = Auditor.find(session[:current_auditor_id])
    auditor = Auditor.authenticate(@current_user.username, params[:old_pass])
    if (auditor == @current_user) && !params[:new_pass].blank? && !params[:confirm_pass].blank?
      if params[:new_pass] == params[:confirm_pass]
          password = params[:new_pass]
          session[:name]= auditor.first_name
          auditor.update_attributes(:password => password, :reset_password => false)
          redirect_to(:controller => :auditor_login, :action=>:switch)
      else
        redirect_to '/auditors/change_password', :notice => 'Confirm password does not match'
      end
    else
      redirect_to '/auditors/change_password', :notice => 'Invalid password'
    end
  end



private
    def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
