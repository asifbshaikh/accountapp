class EmployeeProfileController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Self Service"
    @page_name = "Employee Profile"
    @user_salary_detail = @current_user.user_salary_detail
    @user_information = @current_user.user_information
    @department = @current_user.department
    @designation = @current_user.designation
  end

end
