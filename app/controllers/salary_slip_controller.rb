class SalarySlipController < ApplicationController

  def index
    # @starting_year =  (Time.zone.now.to_date.month < @financial_year.start_date.month ? @financial_year.end_date.year : @financial_year.start_date.year)
    if !params[:month].blank?
      # str = "#{@starting_year}-"+params[:month]+"-01"
      str = params[:month]+"-01"
      @date = Date.parse(str)
    else
      @date = Time.zone.now
    end
    @users =  @company.users.with_salary_structure
    @salaries = Salaries.find_all_by_company_id_and_month(@company.id, @date.beginning_of_month..@date.end_of_month)
  end

  def detail
    @user = User.find_by_id_and_company_id(params[:user_id], @company.id)
    @user_salary_details = @user.user_salary_detail
    @designation = @user.designation
    @month_dates = Salaries.where(:company_id => @company.id).order("month ASC")
    if !@month_dates.blank?
    @months = []
    @month_dates.each do |m|
     @months << (m.month)
    end
    @months
    end

    # if !params[:month].blank?
    #   str = params[:month]+"-01"
    #   @date = Date.parse(str)
    # else
    #   @date = Time.zone.now
    # end

    if params[:month].blank?
      @month = Time.zone.now.to_date.end_of_month
    else
      @month = params[:month].to_s+"-1"
      @month = @month.to_date.end_of_month
    end

    @attendance = Attendance.where("company_id=? and user_id=? and month between ? and ?", @company.id, @user.id, @month.beginning_of_month, @month).first
    # @salaries = SalaryComputationResult.where("amount > ? and user_id = ? and month between ? and ?", 0, params[:user_id], @month.beginning_of_month, @month)


    # Added this to compute Salary Slip from from both tables salaries & salary_computation_results as per params passed by link
    # Author: Ashish Wadekar
    # Date: 6th October 2016
    params[:mode] == "temp" ? @salaries = SalaryComputationResult.where("amount > ? and user_id = ? and month between ? and ?", 0, params[:user_id], @month.beginning_of_month, @month) : @salaries = Salary.where("amount > ? and user_id = ? and month between ? and ?", 0, params[:user_id], @month.beginning_of_month, @month)

    @earning_arr = []
    @earning_amount_arr = []
    @deduction_arr = []
    @deduction_amount_arr = []
    @count = 0
    @total_earning = 0
    @total_deduction = 0
    for salary in @salaries
     payhead = Payhead.find(salary.payhead_id)
     if payhead.payhead_type == "Earnings"
       @earning_arr << payhead.payhead_name
       @earning_amount_arr << salary.amount
       @total_earning +=salary.amount
     else
       @deduction_arr << payhead.payhead_name
       @deduction_amount_arr << salary.amount
       @total_deduction +=salary.amount
     end
    end

    if !@earning_arr.blank? && @earning_arr.length > @deduction_arr.length
      @count = @earning_arr.length
    elsif !@deduction_arr.blank?
      @count = @deduction_arr.length
    end
     prawnto :filename => "salary_slip.pdf"
  end

  end
