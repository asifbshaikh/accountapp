class PayrollDetailsController < ApplicationController
# layout 'payroll'
  def index
    @payroll_details = PayrollDetail.where(:company_id => @company.id)
    @current_month = Time.zone.now.month
    if @company.created_at.to_date > (Time.zone.now.to_date - 6.months)
    	@start_month= @company.created_at.to_date.month>Time.zone.now.to_date.month ? (@company.created_at.month-13) : (@company.created_at.to_date.month-1)
    else
    	@start_month=(@current_month-6)
    end


    @workstreams = Workstream.recent_five(@company, @current_user)
    @holidays = Holiday.this_month(@company)
  end

  def new
  end
end
