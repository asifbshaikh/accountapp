class SignupController < ApplicationController

  layout :false
  skip_before_filter :company_from_subdomain, :authorize_action, :authenticate, :check_messages, :check_if_allow, :company_active?, :current_financial_year, :mix_panel_track

  def index
    @company = Company.new
  end

  def new
    @company = Company.new
    1.times{@company.users.build}
    if params[:payment_id].present? && params[:payment_request_id] .present?
       @pay_details=InstamojoPaymentLink.find_by_payment_request_id(params[:payment_request_id].to_s)
       if @pay_details
       @company.id=InstamojoPaymentLink.find_by_payment_request_id(params[:payment_request_id].to_s).company_id
       # @pay_details=@invoice.instamojo_payment_link.find_by_payment_request_id(params[:payment_request_id])
       # @pay_details=InstamojoPaymentLinks.joins(:company).where("companies.id = instamojo_payment_links.company_id and instamojo_payment_links.payment_request_id=?",params[:payment_request_id])
       end
    end

    if params[:cf_source].present? && params[:plan].present?
       @cashfreedetails= CashfreeResponse.where(:order_id=>params[:cf_source]).last
    end

  end

  def global_pricing
    @company = Company.new
    1.times{@company.users.build}
    @countries = Country.all
  end

  def create
    @company = Company.new(params[:company])
    @company.subdomain = @company.get_available_subdomain
    @company.activation_date = Date.today
    @company.status = 0
    if @company.country_id == 93
      @company.timezone =  "Mumbai"
    else
      @company.timezone = "Eastern Time (US & Canada)"
    end

    plan = Plan.find_by_name(params[:plan])
    ip = request.remote_ip
    respond_to do |format|
      if plan.blank?
        format.html {render :action=> "new"}
        flash[:error] = "No plan selected please register with a plan name to avoid inconvenience"
      else
        if @company.valid?
        begin
        random_string = SecureRandom.hex(4)
        @company.save_with_details(plan, ip, params[:company][:email], random_string)
        user = @company.users.first
        Email.welcome_email(user, random_string).deliver
        #Email.verify_email(user, @company.subscription).deliver #Removed to suit the recent login flow
        session[:name]= user.first_name
        session[:plan]= plan.name
        if !params[:id].blank? && !params[:token].blank?
         pbreferral = Pbreferral.find_by_id_and_token(params[:id], params[:token])
         if !pbreferral.blank?
         if pbreferral.status==0
            user_referral = UserReferral.find_by_company_id_and_user_id(pbreferral.company_id, pbreferral.invited_by)
          if !user_referral.blank?
             pbreferral.update_attributes(:status=>1, :invitee_company_id=> @company.id, :name=> user.first_name)
             new_count = user_referral.registered_referral_count+1
             user_referral.update_attributes(:registered_referral_count => new_count)
             Email.referral_accepted(pbreferral).deliver
          end
         else
           flash[:error] = "You are already registered or not a valid invitee"
         end
        end
        end
        format.html {redirect_to("http://www.profitbooks.net/thanks/")}
        rescue Exception => e
          @company = Company.new
      	  # 1.times{@company.users.build}
          format.html {render :action=> "new"}
          flash[:error] = "There is some error processing, please register again. #{e.message}"
        end
      else
        format.html {render :action=> "new"}
      end
     end
    end
  end
end
