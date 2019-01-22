class Admin::WebinarController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
  

  def index
  	@menu = "Webinar"
  	@page_name = "Webinar Registration"
  	@webinars = Webinar.all
  end

end
