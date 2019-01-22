class PayrollExecutionJobsController < ApplicationController
  def new
    year = (params[:month].to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    @month = Date.new(year, params[:month].to_i, 1)
    @payroll_detail = @company.payroll_details.where("month between ? and ?", @month.beginning_of_month, @month.end_of_month).first
    @attendances = @company.attendances.where(:month => @payroll_detail.month )
    @users = @company.users.this_month_processable(@month)
    @account_heads = AccountHead.get_transferacc_from_heads(@company.id)
    @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
    @last_payroll_execution_job = PayrollExecutionJob.order("execution_date DESC").where("company_id=? and execution_date < ? ",@company.id, Time.zone.now.to_date).first
    account_id = @last_payroll_execution_job.account_id unless @last_payroll_execution_job.blank?
    @payroll_execution_job = PayrollExecutionJob.new(:execution_date=>Time.zone.now.to_date, :account_id=>account_id)
    @variable_payhead_details = VariablePayheadDetail.where(:company_id => @company.id, :month => @month..@month.end_of_month)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_payrolls }
    end
  end

  def create
    @month=params[:month].to_date
    @payroll_detail = @company.payroll_details.where("month between ? and ?", @month.beginning_of_month, @month.end_of_month).first
    @payroll_execution_job = PayrollExecutionJob.create_record(params, @company, @payroll_detail.id)
    respond_to do |format|
      if @payroll_execution_job.save
        @payroll_detail.update_attribute("status", 1)
        user = @company.users.first
        # Email.payroll_request(user, @company).deliver
        # flash[:success] = 'Your payroll request for this month is under processing. We will notify you once it will processed completely'
        PayrollProcessing.perform_async(user.id, @company.id)
        format.html { redirect_to controller: 'payroll_execution_jobs', action: 'processing', month: @payroll_detail.month.month }
        # redirect_to "payroll_execution_jobs/processing?month=#{@payroll_detail.month.month}" }
      else
        @attendances = @company.attendances.where(:month => @payroll_detail.month )
        @users = @company.users.this_month_processable(@month)
        @account_heads = AccountHead.get_transferacc_from_heads(@company.id)
        @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
        @variable_payhead_details = VariablePayheadDetail.where(:company_id => @company.id, :month => @month..@month.end_of_month)
        format.html { render :action => "new" }
      end
    end
  end

  #This method checks for the status of Payroll processing in Salary Computation Result table and redirects the user to results page
  #Author: Ashish Wadekar
  #Date: 10th October 2016
  
  def processing
    @month = params[:month].to_i
    @payroll_processing_check = SalaryComputationResult.check_payroll_processing_status(@company.id, @month)
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end
end
