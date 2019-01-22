class Admin::EmailTemplatesController < ApplicationController
  require "net/http"
  require "uri"

before_filter :menu_title
layout "admin"
  skip_before_filter  :authorize_action, :authenticate , :company_active?, :check_if_allow, :current_financial_year
 before_filter :authorize_super_user
skip_after_filter :intercom_rails_auto_include
 def index
   @email_templates = EmailTemplate.order("created_at DESC").page(params[:page]).per(20)
 end

 def new
  @email_template = EmailTemplate.new
  respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_templates }
    end
 end

 def show
    @email_template = EmailTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_template }
    end
  end

  def edit
    @email_template = EmailTemplate.find(params[:id])
  end

  def create
    @email_template = EmailTemplate.new(params[:email_template])
    respond_to do |format|
      if @email_template.save
        flash[:success]= "Email template successfully created."
        format.html { redirect_to admin_email_templates_url }
        format.xml  { render :xml => @email_template, :status => :created, :location => @email_template }
      else
         format.html { render :action => "new" }
        format.xml  { render :xml => @email_template.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @email_template = EmailTemplate.find(params[:id])

    respond_to do |format|
      if @email_template.update_attributes(params[:email_template])
        format.html { redirect_to(admin_email_templates_url, :notice => 'email_template was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy
    respond_to do |format|
      format.html { redirect_to(admin_email_templates_url) }
      format.xml  { head :ok }
    end
  end
def send_bulk_email
end
def send_email
  @companies = nil
  @users = nil
   if params[:group]== 'all'
      @companies = Company.all
    elsif params[:group]== 'essential'
      @companies = Company.essential_plan
    elsif params[:group]== 'basic'
      @companies = Company.basic_plan
    elsif params[:group]== 'enterprise'
      @companies = Company.enterprise_plan
    elsif params[:group]=='premium'
      @companies = Company.premium_plan
    elsif params[:group] == 'current_month'
      @users = User.current_month
   @users.each do |user|
     to_email = user.email
     subject = params[:subject]
     text = params[:text]
        Email.admin_mail(user, to_email, subject, text).deliver
    flash[:success] = 'Email has been sent successfully.'
   end
 end
   if !@companies.blank?
     @companies.each do |company|
      @users = company.users
      @users.each do |user|
        to_email = user.email
        subject = params[:subject]
        text = params[:text]
          Email.admin_mail(user, to_email, subject, text).deliver
          flash[:success] = 'Email has been sent successfully.'
      end
    end
    elsif @companies.blank? && @users.blank?
        flash[:error]= 'Their is no user in this plan'  
   end
    redirect_to "/admin/email_templates/send_bulk_email"
 end

def weekly_email
  @menu = "Admin"
  @page_name = "Send weekly email"
  @email_template = EmailTemplate.new
  @companies = Company.all
   @companies.each do |company|
      @user = company.users.first
   end
end

 def send_weekly_email
   @companies = Company.all
   
   @companies.each do |company|
     @date = Time.zone.now - 1.weeks
     if company.active?
     @receivable_accounts = Account.get_customer_accounts(company.id)    
      @receivable_hash ={}
      for acc in @receivable_accounts
        @receivable_hash[acc.current_balance] = acc.name
      end
     
      @payable_accounts = Account.get_vendor_accounts(company.id)
      @payable_hash = {}
      for acc in @payable_accounts
        @payable_hash[acc.current_balance] = acc.name
      end
     
      @bank_accounts = Account.get_bank_accounts(company.id)
      @bank_hash ={}
      for acc in @bank_accounts
        @bank_hash[acc.current_balance] = acc.name
      end
     
      @cash_accounts = Account.get_cash_accounts(company.id)
      @cash_hash ={}
      for acc in @cash_accounts
        @cash_hash[acc.current_balance] = acc.name
      end
     @user = company.users.first
     
     @income = company.total_weekly_income(@user, @date)
     @expense = company.total_weekly_expense(@user, @date)
     logger.info"@@@ total income last week #{@income} and expense is #{@expense}"
     
     @email_template = EmailTemplate.find_by_template_name("Weekly Email Header")
     logger.info"@@@ template name is #{@email_template.template_name} and  "
     
     if !@email_template.blank? && !@email_template.header.blank? 
       @header = @email_template.header 
       @footer = @email_template.footer
     end
       logger.info"header is #{@header} and footer is #{@footer}"
    Email.weekly_mail(@user, company, @date, @income, @expense ,@receivable_hash, @payable_hash, @bank_hash, @cash_hash, @header, @footer).deliver
    flash[:success] = 'Email has been sent successfully.'
   end
 end
   redirect_to "/admin/email_templates"
 end

def menu_title
  @menu ="Mail"
  @page_name ="Admin Email "
end
end
