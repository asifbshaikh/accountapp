class PayrollReportsController < ApplicationController
  layout 'payroll'
# def salary_slip
# @menu = "Self Service"
# @page_name = "Salary Slip"
# @user_salary_details = @current_user.user_salary_detail
# @designation = @current_user.designation
# @months = {1 => "January", 2 => "February", 3 => "March", 4 => "April", 5 => "May", 6 => "June", 7 => "July", 8 => "August", 9 => "September", 10 => "October", 11 => "November", 12 => "December"}
# date = Date.today
# if !(params[:month].nil? || params[:month].blank?) && (params[:year].nil? || params[:year].blank?)
# str = "#{Date.today.year}-"+params[:month]+"-01"
# date = Date.parse(str)
# elsif (params[:month].nil? || params[:month].blank?) && !(params[:year].nil? || params[:year].blank?)
# str = params[:year]+"-01-01"
# date = Date.parse(str)
# elsif !(params[:month].nil? || params[:month].blank?) && !(params[:year].nil? || params[:year].blank?)
# str = params[:year]+'-'+params[:month]+'-01'
# date = Date.parse(str)
# end
#
# @salaries = @current_user.salaries.where("month between ? and ?", date.beginning_of_month, date.end_of_month).order(:month)
# @starting_year = Date.today.year
# if @current_user.salaries.count>0
# @starting_year = @current_user.salaries.order(:month).first.month.year
# end
#
# @earning_arr = []
# @earning_amount_arr = []
# @deduction_arr = []
# @deduction_amount_arr = []
# @count = 0
# @total_earning = 0
# @total_deduction = 0
# for salary in @salaries
# payhead = Payhead.find(salary.payhead_id)
# if payhead.payhead_type == "Earnings"
# @earning_arr << payhead.payhead_name
# @earning_amount_arr << salary.amount
# @total_earning +=salary.amount
# else
# @deduction_arr << payhead.payhead_name
# @deduction_amount_arr << salary.amount
# @total_deduction +=salary.amount
# end
# end
# if !@earning_arr.nil? && @earning_arr.length > @deduction_arr.length
# @count = @earning_arr.length
# elsif !@deduction_arr.nil?
# @count = @deduction_arr.length
# end
# end

# def gratuity_report
# @menu = "Self Service"
# @page_name = "Gratuity Report"
# @company = Company.find(User.find(@current_user.id).company_id)
# @users = User.all
# @departments = Department.all
# end
# def employee_profile
# @menu = "Self Service"
# @page_name = "Employee Profile"
# @users=User.find(@current_user.id)
# @user_salary_details = UserSalaryDetail.find_by_user_id(@current_user.id)
# @user_informations = UserInformation.find_by_user_id(@current_user.id)
# @company = Company.find(User.find(@current_user.id).company_id)
# #    @departments=User.find_by_department_id(@current_user.id).name
# @designations=User.find_by_designation_id(@current_user.id)
#
# end
# def payroll_register
#
# @menu = "Self Service"
# @page_name = "Attendance Sheet"
# @users = User.all
# @users=User.find(@current_user.id)
# @user_salary_details = UserSalaryDetail.find_by_user_id(@current_user.id)
# @company = User.find(@current_user.id).company_id.to_i
# #@salary_structures=SalaryStructure.find_by_for_employee(@current_user.id)
# @designations=User.find(@current_user.id).designation_id.to_i
# @designation=User.find_by_designation_id(@current_user.id)
#
#
# end

# def employee_breakup
# @menu = "Self Service"
# @page_name = "Breakup Of Employee"
# @user_in_sal_stru = SalaryStructure.where("for_employee = ?",@current_user.id)
# @payhead=Payhead.where("under=?",'Indirect Expenses')
#
#
# @users = User.all
# @users=User.find(@current_user.id)
#
# @user_salary_details = UserSalaryDetail.find_by_user_id(@current_user.id)
# @company = User.find(@current_user.id).company_id.to_i
# #@salary_structures=SalaryStructure.find_by_for_employee(@current_user.id)
# @designations=User.find(@current_user.id).designation_id.to_i
# @designation=User.find_by_designation_id(@current_user.id)
#
# end
# def payment_advice
# @menu = "Self Service"
# @page_name = "Payment Advice"
# @users = User.all
# @company = Company.find(User.find(@current_user.id).company_id)
# @salary_structure = SalaryStructure.all
# #@user_salary_details = UserSalaryDetail.find_by_user_id(@current_user.id)
# @amount = 0
# for i in @users
# @user_salary = SalaryStructure.find_by_for_employee(i.id)
# if @user_salary.nil?
# @amount += 0
# else
# @amount += @user_salary.amount
# end
# end
# respond_to do |format|
# format.html # show.html.erb
# format.xml  { render :xml => @user }
# format.pdf  { render :layout => false  }
#
# end
# end

# def provident_fund_form5
# @menu = "Self Service"
# @page_name = "Provident Fund Form 5"
# @company = Company.find(User.find(@current_user.id).company_id)
# @users = User.all
# end

# def income_tax_computation
# @menu = "Self Service"
# @page_name = "Income Tax Computation"
# @company = Company.find(User.find(@current_user.id).company_id)
# @user=User.find(@current_user.id)
# @user_salary_detail = UserSalaryDetail.find_by_user_id(@current_user.id)
# @user_information = UserInformation.find_by_user_id(@current_user.id)
# end

# def tds_variance_report
# @menu = "Self Service"
# @page_name = "TDS Variance Report"
# @company = Company.find(User.find(@current_user.id).company_id)
# @users = User.all
# end

# def income_tax_form16
# @menu = "Self Service"
# @page_name = "Income Tax Form 16"
# # @company = Company.find(User.find(@current_user.id).company_id)
# # @user= User.find(@current_user.id)
# @designation= @current_user.designation#User.find(@current_user.id).designation_id.to_i
# end
end
