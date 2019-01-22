class IncomeTaxComputationController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Administration"
    @page_name = "Income Tax Computation"
    @user_salary_detail = @current_user.user_salary_detail
    @user_information = @current_user.user_information
  end

end
