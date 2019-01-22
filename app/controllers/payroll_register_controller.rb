class PayrollRegisterController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Administration"
    @page_name = "Attendance Sheet"
    @users = Company.users
    @user_salary_details = @current_user.user_salary_detail#.find_by_user_id(session[:current_user_id])
  end
end
