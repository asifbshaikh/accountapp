class TdsVarianceReportController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Administration"
    @page_name = "TDS Variance Report"
    @users = @company.users
  end

end
