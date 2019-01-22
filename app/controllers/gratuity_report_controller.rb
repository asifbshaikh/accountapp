class GratuityReportController < ApplicationController
  layout 'payroll'
  def index
    @menu = "Administration"
    @page_name = "Gratuity Report"
    @users = @company.users
    @departments = @company.departments
  end

end
