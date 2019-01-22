class HomeController < ApplicationController
  layout :false
  skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :check_if_allow, :check_messages, :company_active?
  skip_after_filter :intercom_rails_auto_include

  def index
  end

  def features
  end

  def pricing
  end

  def accountant
  end

  def faq
  end

  def contact
  end

  def terms_of_service
  end

  def privacy_policy
  end

   def new_contact
    name = params[:name]
    from_email = params[:email]
    contact = params[:contact]
    message = params[:message]
   channel = Channel.find_by_channel_name("Website Form")

    if !params[:name].blank? && !params[:email].blank? && !params[:contact].blank? && !params[:message].blank?
       Email.website_form(from_email, message, name, contact).deliver
      if !channel.blank?
       Lead.create(:name=>name,:email=>from_email,:mobile=>contact,:description=>message,:channel_id=>channel.id, :lead_type=> 5)
     else
      end
       redirect_to :back
       flash[:success] = 'Email has been sent successfully.'
   else
     redirect_to :back
     flash[:error]='Field with star(*) can not be blank'
  end
 end

 def user_feedback
    company = Company.find_by_subdomain(request.subdomain)
    from_email = company.users.first.email
    message = params[:message]
   if !params[:message].blank?
      Email.user_feedback(from_email, message).deliver
      redirect_to :back
      flash[:success] = 'Email has been sent successfully.'
   else
     redirect_to :back
     flash[:error]='Field with star(*) can not be blank'
    end
 end
  def sitemap

  end

end