class DashboardController < ApplicationController
  skip_before_filter :company_active?, :authenticate, :only => [:setup, :setup_update]
  layout :choose_layout

  def index

    #method call to application helper
    #@months = date_difference_in_months(@financial_year.start_date, Time.zone.now)

    # Total  income
    #logger.debug("Fetching Total Income")
    #@total_income = @company.total_income(@current_user, @financial_year)

    # #total  expenses
    #logger.debug("Fetching Total Expenses")
    #@total_expense = @company.total_expense(@current_user, @financial_year)

    # for a in (@financial_year.start_date.month..@months)
    #   date = Date.new((a > 12 ? @financial_year.end_date.year : @financial_year.start_date.year), (a>12 ? (a -12) : a ), 1)
    # end

    # @monthly_income = Invoice.monthly_income(@company, @current_user)
    # @monthly_expense = Purchase.monthly_expenses(@company, @current_user)

    # @total_monthly_income = @company.total_monthly_income(@current_user,Time.zone.now.to_date)
    #@total_monthly_income = Ledger.total_monthly_income(@company, @current_user)
    present_date = Time.zone.now.to_date
    start_date = present_date.beginning_of_month
    end_date = present_date
    @monthly_income = Invoice.daily_income_amounts(@company, start_date, end_date, @current_user)
    # @total_monthly_expense = @company.total_monthly_expense(@current_user, Time.zone.now.to_date)
    # @total_monthly_expense = Ledger.total_monthly_expense(@company, @current_user)
    #@monthly_expense = Ledger.get_array_of_monthly_expense_amount(@company, @current_user)
    @monthly_expense = Ledger.daily_expense_amounts(@company, start_date, end_date, @current_user)
    mi_max = @monthly_income.max
    me_max = @monthly_expense.max
    @monthly_max = mi_max > me_max ? mi_max : me_max

    #@total_quarterly_income = @company.total_quarterly_income(@current_user,date)
    @last_6month_start_date =Time.zone.now.to_date.beginning_of_month-6.month
    @last_6month_end_date = present_date

    @last_6month_income = Invoice.monthly_income_amounts(@company, @last_6month_start_date, @last_6month_end_date, @current_user)
    #logger.debug("Fetching 10 Days Income")
    #@total_10days_income = @company.total_10days_income(@current_user)
    #logger.debug("Fetching MonthWise Income")
    #@total_monthwise_income = @company.total_monthwise_income(@current_user)

    @last_6month_expenses = Ledger.monthly_expense_amounts(@company, @last_6month_start_date, @last_6month_end_date, @current_user)
    #@total_quarterly_expense = @company.total_quarterly_expense(@current_user, date)
    #logger.debug("Fetching 10 Days Expense")
    #@total_10days_expense = @company.total_10days_expense(@current_user)
    #logger.debug("Fetching Total MonthWise Expense")
    #@total_monthwise_expense = @company.total_monthwise_expense(@current_user)


   #@yearly_income = Invoice.yearly_income(@company, @financial_year, @current_user)
    @yearly_income = Invoice.monthly_income_amounts(@company, @financial_year.start_date, present_date, @current_user)
    #@yearly_expenses = Purchase.yearly_expenses(@company,@financial_year, @current_user)
    #logger.debug "%%%%%%%%%%%%%%%%%%%%%%% #{@yearly_expenses.join(",")} %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    @yearly_expenses = Ledger.monthly_expense_amounts(@company, @financial_year.start_date, present_date, @current_user)
    yi_max = @yearly_income.max
    ye_max = @yearly_expenses.max
    @yearly_max = yi_max > ye_max ? yi_max : ye_max

    #The product graphs
    #the below items are for the inventory manager role
    @product_list = Product.top_15_products(@company, @financial_year)
    #New Rorder products fetching
    @reorder_products = Product.products_near_reorder(@company)


    #[FIXME] rename @products to reorder products
    # logger.debug("Fetching Reorder level products")
    # @products = Product.reorder_level_products(@company)
    @expired_products = Product.expired_products(@company)

    #The Top 5 receivables
    @receivables = Invoice.top_5_unpaid_invoices(@company, @financial_year, @current_user)

    #The invoice status pie chart
    @invoice_counts = Invoice.invoices_status_count(@company,  @financial_year, @current_user)


    #@overdue_expenses = Purchase.overdue_expences(@company, @current_user)
    @overdue_expenses = Purchase.top_5_unpaid_purchases(@company, @current_user)



    @todays_birthday_guys = Dashboard.todays_birthday(@company)

    #logger.debug("Fetching Weeks Birthdays")
    #@weeks_birthday_guys = Dashboard.weeks_birthday(@company)
    @holidays_this_week = Holiday.this_week(@company)


    # Credit invoices amount total
    # logger.debug("Fetching Credit Invoice Amounts.....")
    # @credit_invoice_amount = @company.total_credit_invoice_amount(@current_user, @financial_year)
    # # Total payment received against credit invoices
    # logger.debug("Fetching Payment Received")
    # @payment_received = @company.total_payment_received(@current_user, @financial_year)
    # # total due amount
    # logger.debug("Fetching Total Due")
    # @total_due = @company.total_due(@current_user, @financial_year)
    # # cash invoice amount total
    # logger.debug("Fetching Cash Invoice Amount")
    # @cash_invoice_amount = @company.total_cash_invoice_amount(@current_user, @financial_year)

    @today_tasks = Task.today(@company.id, @current_user.id)
    @week_tasks = Task.this_week(@company.id, @current_user.id)
    # logger.debug("Fetching holidays")
    # @holidays = @company.holidays.find(:all, :conditions => ["holiday_date >= ?", Time.zone.now], :limit => 5)
    # logger.debug("Fetching Users")
    # @users = @company.users

    @bank_accounts = Account.get_bank_accounts(@company.id)
    @cash_accounts = Account.get_cash_accounts(@company.id)
#    @inventories = @company.inventories
    #@inventory_hash ={}
    @workstreams = Workstream.recent_five(@company, @current_user)
    #[FIXME] commented the announcements as I could not find a way owner can post announcements
    #logger.debug("Fetching Announcement")
    #@announcements = Announcement.current(@company, cookies.signed[:hidden_announcement_ids])


    # logger.debug("Fetching Todays Expenses")
    # @expenses = Purchase.today_expences(@company, @current_user)
    # logger.debug("Fetching Paid expenses")
    # @paid_expenses = Purchase.paid_expences(@company, @current_user)
    # logger.debug("Fetching Unpaid Expenses")
    # @unpaid_expenses = Purchase.unpaid_expences(@company, @current_user)
    # logger.debug("Fetching Today's invoices")
    # @invoices = Invoice.today_invoices(@company,@current_user)

    # logger.debug("Fetching Payables")
    # @paybles = Invoice.get_paybles(@company,@financial_year, @current_user)
    # logger.debug("Fetching This week Payables")
    # @week_paybles = Invoice.this_week_paybles(@company,@financial_year, @current_user)
    # logger.debug("Fetching Monthly Payables")
    # @month_paybles = Invoice.this_month_paybles(@company,@financial_year, @current_user)
    # logger.debug("Fetching Estimates")
    # @estimates = Estimate.where(:company_id => 5)
    @leave_requests = LeaveRequest.last_five_pending_approvals @current_user.id
    @timesheets = Dashboard.timesheets(@company,@current_user)

    #logger.debug "-------------------------End Controller---------------------------------------"

    #Getting lead details for checking Demo Status
    @lead = @company.lead
    if @lead.present?
      @demo_status = @lead.lead_activities.where(:next_activity => 2).last.activity_status unless @lead.lead_activities.where(:next_activity => 2).last.blank?
      @demo_completed= @lead.lead_activities.where(:next_activity => 2).last.activity_status unless @lead.lead_activities.where(:next_activity => 2).last.blank?
      if @demo_status == false
        @demo_date = @lead.lead_activities.where(:next_activity => 2).last.next_followup
        @demo_time = @lead.lead_activities.where(:next_activity => 2).last.next_follow_up_time
      end
    end  
  end

  def setup_update
    @company = @company
    #if !params[:fiscal_year].blank? && !params[:you_sell].blank? && !params[:state].blank? && !params[:city].blank? && !params[:business_type].blank? && !params[:industry].blank? && !params[:total_employees].blank?

    #The phone params was removed as per revised sign up flow as it is captured in sign form
    #Author: Ashish Wadekar
    #Date: 16th March 2017
    if !params[:fiscal_year].blank? && !params[:first_name].blank? && !params[:last_name].blank? && !params[:fiscal_year].blank? && !params[:company_ca_status].blank?
      #@company.update_as_setup(params)
      update_error = @company.update_as_welcome_setup(params)
      if update_error.blank?
        session[:financial_year] = @company.financial_years.last.year.name
        flash[:success]="Your setup completed successfully"
        if @company.active?
          redirect_to "/dashboard/index"
        else
          redirect_to "/billing/index"
        end
      else
        update_error.flatten!
        update_error.each do |e|
          flash[:error] = e
        end
        #flash[:error] = "Oops there is an issue"
        redirect_to :back
      end
    else
      flash[:error]="Fields with * are mandatory"
      redirect_to :back
    end
  end

  def setup
    @countries = Country.all
    #@company = @company
    @currencies = Currency.all
    @user = @current_user
  end

  #This method helps in capturing the User information from the form submitted by the user with vital company information
  #The information is updated with the help of update_as_final_setup company method and the user is logged in the system on successful record creation
  #Author: Ashish Wadekar
  #Date: 7th November 2016
  def final_setup_update
    @company = @company
    if !params[:business_type].blank? && !params[:industry].blank? && !params[:total_employees].blank? && !params[:annual_turnover].blank?
      @company.update_as_final_setup(params)
      flash[:success]="Thanks for completing the setup."
      redirect_to dashboard_index_path
    else
      flash[:error]="Fields with * are mandatory"
      redirect_to :back
    end
  end

  def final_setup
    @user = @current_user
  end

  ##This captures the CA related information from the old users
  ##Author: Ashish Wadekar
  ##Date: 10th November 2016
  #def account_management
  #end

  #def account_management_update
  #  if !params[:company_ca_status].blank?
  #    @company.update_ca_status(params)
  #    flash[:success] = "Thank you for completing the setup."
  #    redirect_to dashboard_index_path
  #  else
  #    flash[:error] = "Please select an option before submitting the form"
  #    redirect_to :back
  #  end
  #end

  def add_account
    # @account_heads = nil
    # @account_head = nil
    @data_account = nil
    if params[:transaction_type] == 'debtor'
      @account_heads = AccountHead.get_customer(@company.id)
      @data_account = 'debtor'
    elsif params[:transaction_type] =='sales'
      @account_heads = AccountHead.get_sales_account(@company.id)
      @data_account = 'sales'
    elsif params[:transaction_type] =='taxes'
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = 'taxex'
    elsif params[:transaction_type] =='bank'
      @account_heads = AccountHead.get_bankacc_to_heads(@company.id)
      @data_account = 'bank'
    elsif params[:transaction_type] =='vendor'
      @account_heads = AccountHead.get_vendor_head(@company.id)
      @data_account = 'vendor'
    elsif params[:transaction_type] =='expense'
      @account_heads = AccountHead.get_payment_to_heads(@company.id)
      @data_account = 'expense'
    elsif params[:transaction_type] =='purchase'
      @account_heads = AccountHead.get_purchase_head(@company.id)
      @data_account = 'purchase'
    elsif params[:transaction_type] =='cash'
      @account_heads = AccountHead.get_cashacc_to_heads(@company.id)
      @data_account = 'cash'
    end
  end

  def upgrade_plan
    requested_plan = params[:plan]
    plan = @company.plan
    @company = Company.find(User.find(@current_user.id))
    Email.delay.upgrade_version(requested_plan, plan, @current_user, @company)
    redirect_to dashboard_upgrade_url
    link = "<a href= '/settings/edit'>Click</a>"
    if @company.phone.blank?
      flash[:success] = "Your request has been sent successfully. #{link} to update your contact details.".html_safe
    else
      flash[:success] = "Your request has been sent successfully.Our concerned person will contact you soon on #{@company.phone}.<br/>
                        #{link} to update your contact details.".html_safe
    end
  end

  def set_session
    session[:financial_year] = params[:session_id]
  end

  #report dashboard
  def reports
    @menu = 'Reports'
    @page_name = 'All reports'
  end

  def choose_layout
    case @current_action
    when "setup"
        "login"
    else
      "application"
    end
  end

  def schedule_demo
    @lead_company=LeadCompany.find_by_company_id(@company.id)
    @lead = Lead.find(@lead_company.lead_id)
     # @lead.lead_activities.check_date_validation= true

    lead_activity= Lead.schedule_activity(@lead,params[:lead])
  respond_to do |format|
    if lead_activity
          Email.send_demo_requests(@lead).deliver
          flash[:success]="Your Demo has been Scheduled"
          format.js {render "dashboard/schedule_demo"}
       else
          format.js {render "dashboard/schedule_demo"}
     end
    end
  end
end
