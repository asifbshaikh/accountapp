class ApplicationController < ActionController::Base
  require 'mixpanel-ruby'

  include UrlHelper
  include ApplicationHelper
  include SimpleCaptcha::ControllerHelpers

  #helper_method :address_info
  before_filter :controller_and_action_names
  #the below 4 have to be in the same order
  before_filter :authenticate, :company_from_subdomain
  before_filter :user_from_session, :current_financial_year
  before_filter :authorize_action
  before_filter :check_product_updates
  #before_filter :check_messages
  #before_filter :check_if_allow #if session[:financial_year]
  before_filter :company_active?
  before_filter :set_timezone
  #Disabled intercom events on development
  #before_filter :intercom_events
  #before_filter :mix_panel_track if Rails.env.production?
  # rescue_from Exception, :with => :handle_exceptions
  # skip_after_filter :intercom_rails_auto_include, :if => Proc.new { Rails.env.test? || Rails.env.development? }
  skip_before_filter :check_messages, if: :json_request?

  protect_from_forgery

  #This method validates the email addresses. Multiple emails in the input
  #should be separated by commas
  def validate_email?(email_string)
    #return false if email is blank
    return false if email_string.blank?
    #remove all white space
    to_email = email_string#.gsub(/\s+/, "")
    #check for presence of multiple emails
    if(to_email.count(',')>0 && to_email.count(',')<6)
      result = true
      emails_array = to_email.split(",")
      emails_array.each do |email|
        if !valid_email_address?(email.squish)
          result = false
          break
        end
      end
      return result
    else
      return valid_email_address?(to_email)
    end
  end

  #The emails are validated by making an call to the Ruby Mail library
  #http://blog.endpoint.com/2014/10/parsing-email-addresses-in-rails.html
  def valid_email_address?( value )
    begin
     parsed = Mail::Address.new(value)
     return parsed.address == value && parsed.local != parsed.address
    rescue Mail::Field::ParseError
      return false
    end
  end


  private
    #this method is used for disabling the message check filter for JSON requests
    def json_request?
      request.format.json?
    end

    def intercom_events
      if Rails.env.production?
        unless @current_user.blank?
          Intercom.app_id = "402c2c9d003ab5c965babf93ec504bed456a7bc4"
          Intercom.api_key = "065d35a9ccd7d2d3d8ebb51d3279af9e5b5ac0ef"
          begin
            user=Intercom::User.find_by_user_id(@current_user.id)
            Intercom::Event.create({:event_name => "#{@current_controller}/#{@current_action}", :user=>user})
          rescue Exception => e
          end
        end
      end
    end
    
    #for current company
    def company_from_subdomain
      @company ||= Company.find(session[:company_id])
    end

    #for current user to use through out the app
    def user_from_session
      if session[:current_user_id].present?
        @current_user ||= User.find(session[:current_user_id])
      elsif session[:current_auditor_id].present?
        @current_user ||= Auditor.find(session[:current_auditor_id])
      elsif session[:current_super_user_id].present?
        @current_user ||= SuperUser.find(session[:current_super_user_id])
      end
    end

    # for current financial year
    def current_financial_year
      year = Year.find_by_name(session[:financial_year])
      if @company.plan.foreign_plan?
        year = @company.financial_years.last.year
      end
      @financial_year ||= FinancialYear.find_by_company_id_and_year_id(@company.id, year.id)
    end

    # for checking whether current financial year is freezed or not
    def allow_entry?
      #current_financial_year.is_freezed?
      @financial_year.is_freezed?
    end


    #Check for all application request if logged in user session is valid.
    def authenticate
      unless User.find_by_id(session[:current_user_id]) ||
        (Auditor.find_by_id(session[:current_auditor_id]))
        redirect_to ({:controller => :login, :action => :session_timeout})
      end
    end

    def authorize_super_user
      unless SuperUser.find_by_id(session[:current_super_user_id])
        redirect_to ({:controller => "admin/login", :action => :signout})
       end
    end

    # Action to handle super user and normal user login in same browser
    def end_session
      if !User.find_by_id(session[:current_user_id]).blank? && !SuperUser.find_by_id(session[:current_super_user_id]).blank?
        flash[:error] = "Don't be too smart."
        redirect_to ({:controller => :login, :action => :signout})
      end
    end

    def authorize_action
      if(['index','create','new','edit','update','delete','destroy'].include?(action_name))
        unless @current_user.can?(action_name, controller_name)
          flash[:error] = 'You are not authorized to access this function.'
          redirect_to :back
        end
      else
        true
      end
    end

    def check_if_allow
      if(['create','new','edit','update','delete','destroy'].include?(action_name))
        if allow_entry?
          flash[:error] = "You can not make any changes in this financial year as the records are audited and freezed. You can get in touch with company owner or accountant for more information."
          redirect_to :back
        end
      else
        true
      end
    end

    #Action to check the subscription end date and prevent user to use any link if
    def company_active?
      if !@company.blank? && !@company.active? && !@company.plan.free_plan?
        flash[:error] = "Your subscription has been deactivated, renew your subscription to activate again.".html_safe
        redirect_to "/billing/index"
      end
    end

    def check_active_session?
      if !session[:current_user_id].blank?
       #redirect_to(:subdomain => @company.subdomain, :controller => :dashboard, :action => :index)
       redirect_to(:controller => :dashboard, :action => :index)
      elsif !session[:current_super_user_id].blank?
       redirect_to(:controller => "admin/dashboard", :action => :index)
      end
    end

#---------------- exception handling------------------------------
    def handle_exceptions(e)
      logger.error(e.backtrace)
      ErrorMailer.experror(e, @current_user, request.original_url).deliver
      render :template => "error_mailer/show_msg", :status => 500
    end
#---------------------end of exception handling-----------------

    def controller_and_action_names
      @current_action = action_name
      @current_controller = controller_name
      #why does this need to be here?
      # @years = @company.financial_years unless @company.blank?
      #current_app( controller_name )
    end

    def check_messages
      @msg_cnt = Message.message_count session[:current_user_id].to_i
    end

    def check_product_updates
      @product_updates ||= ProfitbooksWorkstream.new_updates
    end

    def mix_panel_track
      if @company.plan.trial_plan?
        tracker = Mixpanel::Tracker.new('ae362b731df648a210bf492757811714')
        event = "#{@current_controller} #{@current_action}"
        tracker.track(@current_user.id.to_s, event)
      end
    end

    def redirect_back_or_default(default = root_path, options = {})
  redirect_to (request.referer.present? ? :back : default), options
end

end
