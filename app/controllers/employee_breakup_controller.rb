class EmployeeBreakupController < ApplicationController

  def index
    @user_in_sal_stru = SalaryStructure.where("for_employee = ?",session[:current_user_id])
    @payheads = @company.payheads.all
    @users = @company.users.with_salary_structure
    # @user_salary_details = @current_user.user_salary_detail
    @company= @company
    @month_dates = Salaries.where(:company_id => @company.id).order("month ASC")

    @months = []
    @month_dates.each do |m|
     @months << (m.month)
    end
    @months

  	if !params[:month].blank?
      str = params[:month]+"-01"
      @date = Date.parse(str)
    else
       @date = Time.zone.now
    end
    @salaries=Salaries.where(:company_id =>@company.id, :month =>@date.beginning_of_month..@date.end_of_month)
end

def breakup_for_employee
	@user_id = params[:name].blank? ? @current_user.id : params[:name]
  @payheads= @company.payheads.all
	@users = @company.users.with_salary_structure
  @months = []
  (@financial_year.start_date..@financial_year.end_date).each do |m|
     @months << m.beginning_of_month
  end
  @months
end

end
