class Admin::CompaniesController < ApplicationController
  respond_to :html, :json
  layout "admin"
  skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user, :menu_title
  skip_after_filter :intercom_rails_auto_include, :intercom_events

  def index
    respond_to do |format|
      format.html #company_details.html.erb
      format.html # new.html.erb
      format.xls
      format.json { render :json => CompanyDatatable.new(view_context)}
    end
  end

  def workstream
    @company = Company.find(params[:id])
    @menu = "Recent Activities"
    @page_name = "#{@company.name}"
    # @workstreams = Workstream.where(:company_id => @company.id).order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workstreams }
      format.json { render :json => WorkstreamDatatable.new(view_context,@company,"")}
    end
  end

  def this_week
    @companies = Company.this_week.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @companies }
    end
  end

  def this_month
    @companies = Company.this_month.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @companies }
    end
  end

  def this_year
    @companies = Company.this_year.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @companies }
    end
  end

  def paid_companies
    @subscriptions = Subscription.paid_subscription.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @subscriptions }
    end
  end

  def expiring_this_week
    @subscriptions = Subscription.expiring_this_week.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @subscriptions }
    end
  end

  def expiring_in_15_days
    @subscriptions = Subscription.expiring_in_15_days.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @subscriptions }
    end
  end

  def company_closed
    @companies = Company.closed.page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xls
      format.xml  { render :xml => @companies }
    end
  end

  def show
     @company = Company.find(params[:id])
     owner_array = Role.owner_list
     @owner_list = @company
     @owner = Company.get_owners(@company.id)
     # @subscriptions = @company.subscriptions.where(:status_id=>1)
     @mail_sender = @current_user
     @company_notes = @company.company_notes
     @company_emails = EmailTemplate.where(:company_id => @company.id).order("created_at DESC")
     @plans = Plan.all
     @subscription = Subscription.find_by_company_id_and_status_id(@company.id, 1)
     @workstreams = Workstream.where(:company_id => @company.id).order("created_at DESC").page(params[:page]).per(10)
     @completed_customer_relationships = @company.customer_relationships.where(:activity_status => true).order("next_contact_date DESC")
     @incompleted_customer_relationships = @company.customer_relationships.where(:activity_status => false).order("next_contact_date ASC")
     @lead = @company.lead
     if @lead.blank?
      @incomplete_lead_activities = []
       @complete_lead_activities =[]
     else
      @incomplete_lead_activities = @lead.lead_activities.where(:activity_status => false).order("next_followup ASC")
       @complete_lead_activities = @lead.lead_activities.where(:activity_status => true).order("next_followup DESC")
    end
     @company.customer_relationships.build
  end
# DELETE /companies/1
  # DELETE /companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end

  def resend_welcome_email()
     @company = Company.find(params[:id])
     @subscription = Subscription.find_by_company_id_and_status_id(@company.id, 1)

    if !@subscription.blank?
      user = @subscription.company.users.first
      plan = @subscription.plan
      Email.signup_confirmation(user, plan).deliver #unless subscription.status_id == 1
      redirect_to admin_company_path(@company)
      flash[:success] = "Email has been sent successfull"
    else
       flash[:error] = "Something went wrong"
    end
  end

 def green
    @menu = 'Company'
    @page_name = 'List of companies'
    @companies = Company.green.page(params[:page]).per(20)
     @plans = Plan.all
     if !@plans.blank?
      if !params[:plan].blank?
        @plan = Plan.find(params[:plan])
        @companies = @plan.companies.page(params[:page]).per(20)
      end
    end
 end
 def amber
    @menu = 'Company'
    @page_name = 'List of companies'
    @companies = Company.amber.page(params[:page]).per(20)
     @plans = Plan.all
     if !@plans.blank?
      if !params[:plan].blank?
        @plan = Plan.find(params[:plan])
        @companies = @plan.companies.page(params[:page]).per(20)
      end
    end
 end
 
 def red
    @menu = 'Company'
    @page_name = 'List of companies'
    @companies = Company.red.page(params[:page]).per(20)
     @plans = Plan.all
     if !@plans.blank?
      if !params[:plan].blank?
        @plan = Plan.find(params[:plan])
        @companies = @plan.companies.page(params[:page]).per(20)
      end
    end
 end

 def renew
     @menu = 'Company'
     @page_name = 'Update Renewal Date'
     @company = Company.find(params[:id])
     @user = @company.users.first
     @subscription = @company.subscription

     respond_to do |format|
     if @subscription.update_attributes(params[:subscription])
        Email.renewal_date_update(@user, @company).deliver
        @subscription.update_attribute("end_date", @subscription.renewal_date)
        format.html { redirect_to( admin_company_path(@company), :notice => 'Company renewal date successfully updated.') }
        format.xml  { head :ok }
      else
         format.html {redirect_to :back}
        flash[:error] = "New renewal date can not be blank"
     end
    end
 end

 #This method was added to reset the password of user and send the welcome email again with a temporary password
 #Author: Ashish Wadekar
 #Date: 14th November 2016
 def reset_user_password
  company = Company.find(params[:id])
  if company.reset_owner_password
    flash[:success] = "The password for owner of #{company.name} was reset successfully. Welcome email sent to user."
    redirect_to :back
  else
    flash[:error] = "There was some error while sending the welcome email. Please try again later."
    redirect_to :back
  end  
 end

 def upgrade_plan
   @company = Company.find(params[:id])
   @user = @company.users.first
   @plans = Plan.all
   @subscription = @company.subscription
   respond_to do |format|
    if @subscription.upgrade_plan_from_admin(params[:subscription][:plan_id], params[:subscription][:renewal_date].to_date, @company.financial_years[0])
      Email.plan_updated(@user, @company).deliver
      format.html { redirect_to( admin_company_path(@company), :notice => 'Company plan successfully updated.') }
      format.xml  { head :ok }
    else
        format.html {redirect_to :back}
        flash[:error] = "Something went wrong"
    end
   end
 end
 def update
     @company = Company.find(params[:id])
     # @user = @company.users.first
     respond_to do |format|
     if @company.update_attributes(params[:company])
        format.js {render "admin/companies/add_activity"}
        format.html { redirect_to( admin_company_path(@company), :notice => 'Company successfully updated.') }
        format.xml  { head :ok }
      else
        format.js {render "admin/companies/add_activity"}
         format.html {redirect_to :back}
        flash[:error] = "Something went wrong"
     end
    end

 end

def expiring_this_month
    # @expiring_this_month = Company.expiring_this_month
    respond_to do |format|
      format.html #company_details.html.erb
      format.html # new.html.erb
      format.xls
      format.xml  { render :xml => @companies }
      format.json { render :json => CompanyDatatable.new(view_context)}
    end
end

def update_followup
    @lead_activity = CustomerRelationship.find(params[:activity_id])
    @lead_activity.update_attributes(:notes => params[:notes], :time_spent => params[:time_spent], :activity_status => true, :completed_date => Time.zone.now.to_date, :created_by => params[:created_by])
end

def add_activity
  @company = Company.find(params[:id])
     # @user = @company.users.first
    respond_to do |format|
    if @company.update_attributes(params[:company])
      if @company.customer_relationships.last.activity_status == true
        @company.customer_relationships.last.update_attributes(:completed_date => Time.zone.now.to_date)
      end
        format.js {render "admin/companies/add_activity"}
    else
        format.js {render "admin/companies/add_activity"}
     end
    end
end
def report_charts
    @financial_year = params[:year]
    @monthly_registrations = Company.monthly_registrations(params)
    @monthly_leads = Lead.monthly_leads(params)
    @paid_users = Company.paid_users(params)
    @pwyw_users = Company.free_plan
    @smb_users = Company.smb_plan
    @trial_users = Company.trial_plan
    @enterprize_users = Company.enterprise_plan
    @professional_users = Company.professional_plan
    @super_users = SuperUser.all
    @piechart_slices = Company.get_piechart_slices(@super_users.count)
    @users_companies = Company.get_users_companies
    @company_count = Company.get_company_count(@users_companies)
end
def send_email
    to_email = params[:email]
    cc = params[:cc]
    subject = params[:subject]
    text = params[:text]
    mail_sender = @current_user.full_name
    from = @current_user.email
    company_id = params[:company_id].to_i
    template = params[:select_template].to_i
    template_name = CustomerRelationship.get_template(template)
    if !params[:email].blank?
      Email.send_leads_email(to_email,cc,subject, text,from,mail_sender).deliver
      EmailTemplate.create(:company_id => company_id, :email => to_email, :template_name => template_name, :subject => subject, :created_by => @current_user.id )
      flash[:success] = 'Email has been sent successfully.'
    else
      # redirect_to :back
      flash[:error]='Email can not be blank'
    end
  end
  def select_template
    @template_value = params[:template_value]
  end
  def activity_reports
    @start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @super_user = SuperUser.all
    @companies = Company.get_customer_relationships(params)
  end

  def reports

  end

  def sales_by_user
    @start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @sales_person = params[:super_user].blank? ? SuperUser.first.id : params[:super_user]
    @super_user = SuperUser.all
    @sales_by_user = BillingInvoice.get_sales_by_user(params)
  end
  def sales_cycle
    @sales_cycle_for_paid = Company.get_sales_cycle_for_paid
  end

  def weekly_shedule
    @weekly_companies_shedule = CustomerRelationship.get_weekly_shedule
    @weekly_leads_shedule = LeadActivity.get_weekly_activities
  end

  def task_delay_report

    respond_to do |format|
      format.html #task_delay_report.html.erb
      format.json { render :json => ReportDatatable.new(view_context)}
    end
  end

 private
 def menu_title
   @menu = "Company"
   @page_name = "List of companies"
 end
end
