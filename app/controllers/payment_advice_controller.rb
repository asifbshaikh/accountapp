class PaymentAdviceController < ApplicationController
  def index
    @month_dates = Salaries.where(:company_id => @company.id).order("month ASC")
    @months = []
    @month_dates.each do |m|
     @months << (m.month)
    end
    @users = @company.users.with_salary_structure
    # We made some changes durig payroll revamp. After that changes, 1st date of month get saved in month field 
    # of payroll_details table. But in some older record, randome records might be present. I am retriving
    # payroll_detail on the basis of old logic as well as new one. That why old_fashion_date variable used.
    old_fashion_date = params[:month].blank? ? Time.zone.now.to_date : params[:month].to_date
    @date=params[:month].blank? ? Time.zone.now.to_date.beginning_of_month : params[:month].to_date.beginning_of_month
    @payroll_detail = PayrollDetail.find_by_company_id_and_month_and_status(@company.id, [@date, old_fashion_date], 2)
    unless @payroll_detail.blank? 
      @payroll_execution_job=@payroll_detail.get_payroll_execution_job
      if !@payroll_execution_job.blank?
        @account = @company.accounts.find_by_id(@payroll_execution_job.account_id)
      end
      @salaries=Salaries.where("company_id=? and amount>? and month between ? and ?",@company.id ,0 ,@date, @date.end_of_month)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.pdf do
        pdf=PaymentAdvicePdf.new(@date, @users, @payroll_detail, @account, @company)
        send_data pdf.render, :file_name=>"payment_advice_#{@date.strftime('%B_%y')}.pdf", :desposition=>"inline", :type=>"application/pdf"
      end
      format.xls  { render :layout => false  }
    end
  end
end