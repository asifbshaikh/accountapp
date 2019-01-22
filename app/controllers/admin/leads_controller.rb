class Admin::LeadsController < ApplicationController
  respond_to :html, :json
  layout "admin"

  skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
  before_filter :page_menu
  skip_after_filter :intercom_rails_auto_include, :intercom_events

  def index
    # @search = Lead.search(params[:search])
    #@leads = Lead.where(:deleted => false).order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json { render :json => LeadDatatable.new(view_context, @current_user)}
    end
  end

  def new
    @lead = Lead.new
    @channel = Channel.new
    @campaign = Campaign.new
    @channels = Channel.all
    @campaigns = Campaign.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @leads }
    end
  end

  def show
    @lead = Lead.find(params[:id])
    @mail_sender = @current_user
    @company_emails = EmailTemplate.get_email_template(@lead)
    @customer_relationships = @lead.customer_relationships.order("created_at DESC")
    @lead.customer_relationships.build
    @complete_lead_activities = @lead.lead_activities.where(:activity_status => true).order("next_followup DESC")
    @incomplete_lead_activities = @lead.lead_activities.where(:activity_status => false).order("next_followup ASC")
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  def edit
    @lead = Lead.find(params[:id])
    @channels = Channel.all
    @campaigns = Campaign.all
  end

  def create
    @lead = Lead.new(params[:lead])

    @channels = Channel.all
    @campaigns = Campaign.all
    @channel = Channel.new
    @campaign = Campaign.new

    respond_to do |format|
      if @lead.save
        next_follow_up_time = params[:next_follow_up_time]
        LeadActivity.create(:lead_id => @lead.id, :next_followup => @lead.next_call_date, :next_follow_up_time => next_follow_up_time, :next_activity => 19, :outcome => @lead.description )
        flash[:success]= "Lead successfully created."
        format.html { redirect_to "/admin/leads/#{@lead.id}" }
        format.xml  { render :xml => @lead, :status => :created, :location => @lead }
      else
       format.html { render :action => "new" }
       format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
     end
   end
 end


  def update
    @lead = Lead.find(params[:id])
    @channels = Channel.all
    @campaigns = Campaign.all
    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        @lead.update_attributes(:next_call_date => @lead.lead_activities.last.next_followup) unless @lead.lead_activities.blank?
        if @lead.lead_activities.last.activity_status == true
          @lead.lead_activities.last.update_attributes(:completed_date => Time.zone.now.to_date)
        end
        format.html { redirect_to([:admin, @lead], :notice => 'Activity successfully updated.') }
        format.json { head :ok }

      else
        flash[:error] = 'Date should not be blank'
        format.html { redirect_to([:admin, @lead])}
        format.json { respond_with_bip(@lead) }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy
    respond_to do |format|
      format.html { redirect_to(admin_leads_url) }
      format.xml  { head :ok }
    end
  end

  def assign
    @lead = Lead.find(params[:id])
    @lead.assign_to_user(@current_user)
  end

  def junk
    @lead = Lead.find(params[:id])
    @lead.mark_as_junk(@current_user)
  end

  def qualified
    @lead = Lead.find(params[:id])
    @lead.mark_as_qualified(@current_user)
  end


  def add_channel
    @data_channel = nil
  end
  def add_campaign
  	@data_campaign = nil
  end

  def change_user
    @lead = Lead.find(params[:id])
    logger.debug "===========The change user params are #{params.inspect}========="
    @user = SuperUser.find(params[:assigned_to])
    @lead.assign_to_user(@user)
  end


  def create_channel
    @is_save = false
    @channel = Channel.new(params[:channel])

    if @channel.save
      @is_save = true
    else
      @is_save = false
    end
  end

  def create_campaign
  	@is_save = false
    @campaign = Campaign.new(params[:campaign])

    if @campaign.save
      @is_save = true
    else
      @is_save = false
    end
  end


  def update_activity
    @lead_activity = LeadActivity.find(params[:activity_id])
    @lead_activity.check_date_validation=false
    @lead_activity.update_attributes(:outcome => params[:outcome], :time_spent => params[:time_spent], 
      :activity_status => true, :completed_date => Time.zone.now.to_date)

  end

  def mark_lost
    @lead = Lead.find(params[:id])
    @lead.mark_as_lost(params[:reason_delete], params[:comment], @current_user)
  end

  def restore_lead
    @lead = Lead.find(params[:id])
    @lead.update_attributes(:deleted => false)
    respond_to do |format|
      format.html {redirect_to(admin_leads_url)}
    end
  end

  def convert_to_paid
    @lead = Lead.find(params[:id])
    @lead.update_attributes(:payment_status => true, :stage => 3, :next_call_date => Time.zone.now.to_date + 1.days, :converted_comment => params[:reason],:converted_by =>@current_user)
    respond_to do |format|
      format.html {redirect_to([:admin, @lead], :notice => "Lead successfully converted to paid")}
    end
  end

  def convert_to_trial
    @lead = Lead.find(params[:id])
    @lead.update_attributes(:converted_to_trial => true, :converted_by =>@current_user)
    respond_to do |format|
      format.html {redirect_to([:admin, @lead], :notice => "Lead successfully converted to trial")}
    end
  end
  def convert_to_unpaid
    @lead = Lead.find(params[:id])
    @lead.update_attributes(:payment_status => false,:converted_by =>@current_user)
    respond_to do |format|
      flash[:success] = 'Lead successfully converted to unpaid'
      format.html {redirect_to(admin_leads_url)}
    end
  end

  def activity_reports
    @start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @super_user = SuperUser.where(:active => true)
    @leads = Lead.get_lead_activities(params)
  end

  def time_consumed_by_activities
    @start_date = params[:start_date].blank? ? Time.zone.now.beginning_of_month.to_date : params[:start_date]
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]
    activity = params[:activity].blank? ? LeadActivity::ACTIVITY.keys : params[:activity]
    @super_user = SuperUser.where(:active => true)
    @activities = LeadActivity.get_activities(params)
  end

  def channel_summary
    if params[:month].blank?
      @month_date = Time.zone.now.to_date
    else
      @month_date = Date.parse(params[:month]).to_date
    end
    @channels = Channel.all
    @months = []
    financial_year = (Time.zone.now.beginning_of_year+3.months).to_date..(Time.zone.now.end_of_year+3.months).to_date
    financial_year.each do |m|
      if @months.include?(m.beginning_of_month.to_date)
      else
        @months << m.beginning_of_month.to_date
      end
      @months
    end
    @leads = Lead.get_channel_summary(params)
  end

  def lead_reports
    @leads = Lead.get_lead_record(params)
  end

  def todays_leads
    @leads = Lead.todays_leads.page(params[:page]).per(20)
  end

  def pending_leads
    @leads = Lead.pending_leads(params).page(params[:page]).per(20)
  end

  def paid_leads
    @leads = Lead.paid_leads.page(params[:page]).per(20)
  end

  def unpaid_leads
    @leads = Lead.unpaid_leads.page(params[:page]).per(20)
  end
  def deleted_leads
    @leads = Lead.where(:deleted => true)
    @not_interested = @leads.where(:deleted_reason => 1).count
    @lost_to_competion = @leads.where(:deleted_reason => 2).count
    @junk = @leads.where(:deleted_reason => 3).count
    @feature_missing = @leads.where(:deleted_reason => 4).count
    @pricing_issue = @leads.where(:deleted_reason => 5).count
    @other = @leads.where(:deleted_reason => 6).count
  end

  def send_email
    to_email = params[:email]
    cc = params[:cc]
    subject = params[:subject]
    text = params[:text]
    mail_sender = @current_user.full_name
    from = @current_user.email
    company_id = params[:company_id].to_i
    template = params[:select_email_template].to_i
    template_name = CustomerRelationship.get_template(template)
    if !params[:email].blank?
      Email.send_leads_email(to_email,cc,subject, text,from,mail_sender).deliver
      unless company_id.blank?
        EmailTemplate.create(:company_id => company_id, :email => to_email, :template_name => template_name, :subject => subject, :created_by => @current_user.id )
      end
      flash[:success] = 'Email has been sent successfully.'
    else
      # redirect_to :back
      flash[:error]='Email can not be blank'
    end
  end

  #method for partial.js(ajax)
  def lead_action

  end

  def select_template
    @template_value = params[:template_value]
  end

  def add_activity
    @lead = Lead.find(params[:id])
    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        if @lead.lead_activities.last.activity_status == true
          @lead.lead_activities.check_date_validation=false
          @lead.lead_activities.last.update_attributes(:completed_date => Time.zone.now.to_date)
        end
        format.js {render "admin/leads/add_activity"}
      else
        format.js {render "admin/leads/add_activity"}
      end
    end
  end

  def request_demo
   @leads = Lead.where(:deleted => false).order("created_at DESC").page(params[:page]).per(20)
   respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json { render :json => RequestDemoDatatable.new(view_context, @current_user)}
    end

  end

  def page_menu
    @menu = "Lead"
    @page_name = "Lead activities"
  end
end

