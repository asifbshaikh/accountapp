class ProvidentFundFormController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Administration"
    @page_name = "Provident Fund Form 5"
    #@company = Company.find(User.find(session[:current_user_id]).company_id)
    @users = @company.users
  end

end
