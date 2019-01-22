class IncomeTaxForm16Controller < ApplicationController
  layout 'payroll'
  def index
    @menu = "Self Service"
    @page_name = "Income Tax Form 16"
    @designation= @current_user.designation
  end

end
