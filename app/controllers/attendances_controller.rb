class AttendancesController < ApplicationController
  # GET /attendances
  # GET /attendances.xml
  def index
    year = (params[:month].to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    @month = Date.new(year, params[:month].to_i, 1)
    @payroll_detail = @company.payroll_details.where("month between ? and ?", @month.beginning_of_month, @month.end_of_month).first
    @attendances = @company.attendances.where(:month => @payroll_detail.month )
    @users = @company.users.this_month_processable(@month)
    @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
    @payroll_execution_job = PayrollExecutionJob.order("execution_date DESC").where("company_id=? and execution_date < ? ",@company.id, Time.zone.now.to_date).first
     @variable_payhead_details = VariablePayheadDetail.where(:company_id => @company.id, :month => @month..@month.end_of_month)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_payrolls }
    end
  end

  # GET /attendances/1
  # GET /attendances/1.xml
  def show
    year = (params[:month].to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    @month = Date.new(year, params[:month].to_i, 1)
    @payroll_detail = PayrollDetail.where("company_id=? and month between ? and ? ", @company.id, @month, @month.end_of_month).first
    @attendances = Attendance.where(:company_id => @company.id, :month => @payroll_detail.month)
    @users = User.where(:company_id => @company).this_month_payroll_participation(@month)
    @payroll_execution_job = PayrollExecutionJob.where("company_id=? and payroll_detail_id=?", @company.id, @payroll_detail.id ).first
    @payroll_accounts_details = SalaryComputationResult.where(:company_id => @company.id, :month => @month.beginning_of_month..@month.end_of_month)
    @payroll_accounts_details_status = @payroll_accounts_details.first.status unless @payroll_accounts_details.blank?
    
    if @payroll_accounts_details.blank?
      @payroll_accounts_details = Salary.where(:company_id => @company.id, :month => @month.beginning_of_month..@month.end_of_month)
      @payroll_accounts_details_status = 1
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /attendances/new
  # GET /attendances/new.xml
  def new
    @attendance = Attendance.new
    @payheads = @company.payheads.where(:optional => true)
    year = (params[:month].to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    @month = Date.new(year, params[:month].to_i, 1)
    @users = @company.users.this_month_processable(@month)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attendance }
    end
  end


  # POST /attendances
  # POST /attendances.xml
  def create
    # year = (params[:month].to_i < @financial_year.start_date.month ? @financial_year.end_date.year : @financial_year.start_date.year)
    year = (params[:month].to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    @month = Date.new(year, params[:month].to_i, 1)
    @users = @company.users.this_month_processable(@month)

    respond_to do |format|
      result=true
      ActiveRecord::Base.transaction do
        @users.each do |user|
          unless user.salary_structure.blank?
            begin
              Attendance.create!(:company_id=>@company.id, :user_id=>user.id, :month=>@month,
                :days_absent=> params[:attendance]["#{user.id}"][:days_absent])
            rescue Exception => e
              result=false
              raise ActiveRecord::Rollback
            end
          end
        end
      end

      if result
        payroll_detail = PayrollDetail.create_record(@company, @current_user, @month)
        flash[:success] = 'This is your employees attendance record for this month. You can request for processing payroll by clicking on "Process payroll" button.'
        format.html { redirect_to "/payroll_execution_jobs/new?month=#{@month.month}" }
      else
        @payheads = @company.payheads.where(:optional => true)
        flash[:error] = "Days absent can not be blank or greater than #{@month.end_of_month.day}."
        format.html { render :action => "new" }
      end
    end
  end

 def process_payroll
    @payroll_detail = PayrollDetail.find_by_company_id_and_month(@company.id, params[:month])
    @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
    if !params[:account_name].blank? && !params[:execution_date].blank?
      @payroll_execution_job = PayrollExecutionJob.create_record(params, @company)
      if @payroll_execution_job.save && @payroll_detail.update_attribute("status", 1)
        user = @company.users.first
        Email.payroll_request(user, @company).deliver
        flash[:success] = 'Your payroll request for this month is under processing. We will notify you once it will processed completely'
        redirect_to "/attendances/show?month=#{@payroll_detail.month.month}"
      else
       flash[:error]= "Something went wrong."
      end
   elsif !params[:execution_date].blank? && params[:execution_date].to_date < Time.zone.now.to_date
     flash[:error] = "Execution date should not be less than today's date."
     redirect_to "/attendances?month=#{@payroll_detail.month.month}"
   else
      flash[:error]= "Field with star can not be blank."
     redirect_to "/attendances?month=#{@payroll_detail.month.month}"
   end
 end

 # GET /attendances/1/edit
  def edit
    @data_attendance = nil
    @attendance = Attendance.find(params[:id])
    @users = @company.users
    @payheads = @company.payheads.where(:optional => true)
  end
  # PUT /attendances/1
  # PUT /attendances/1.xml
  def update
    @is_save = false
    @attendance = Attendance.find(params[:id])
 #respond_to do |format|
      if !params[:attendance].blank? && @attendance.update_attributes(params[:attendance])
        flash[:success] = "Attendance updated successfully"
        redirect_to "/attendances/show?month=#{params[:month]}"
        @if_save = true
      else
        @if_save = false
        flash[:error] = "Attendance can't be blank"
        render :action => "edit"
      end
    #end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.xml
  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy

    respond_to do |format|
      format.html { redirect_to(attendances_url) }
      format.xml  { head :ok }
    end
  end


  # def add_variable_payhead_detail
  #   @data_variable_payhead_detail = nil
  #   @users = @company.users
  #   @payheads = @company.payheads.where(:optional => true)
  #   @salary_structure = SalaryStructure.find_by_company_id_and_for_employee(@company.id, params[:user_id])
  #   @salary_structure_line_items = SalaryStructureLineItem.find_by_salary_structure_id(@salary_structure.id) unless @salary_structure.blank?
  #   @variable_payhead_detail = VariablePayheadDetail.new
  # end

  def create_variable_payhead_detail
    @salary_structure = SalaryStructure.find_by_id params[:salary_structure_id]
    @user = User.find_by_id(params[:user_id])
    unless @user.blank?
      if @user.update_attributes!(params[:user])
      end
    end
   #  @is_save = false
   #  @users = @company.users
   #  @payheads = @company.payheads.where(:optional => true)
   #  @salary_structure = SalaryStructure.find_by_id(params[:id])
   #  year = (params[:month].to_i < @financial_year.start_date.month ? @financial_year.end_date.year : @financial_year.start_date.year)
   #  date = Date.new(year, params[:month].to_i, Time.zone.now.to_date.day)
   #  @payheads.count.times do |i|
   #  if !params[:variable_payhead_detail][:amount][i].blank? && @variable_payhead_detail = VariablePayheadDetail.new(
   #     :payhead_id => params[:variable_payhead_detail][:payhead_id][i],
   #     :user_id => @salary_structure.for_employee,
   #     :company_id => @company.id,
   #     :amount => params[:variable_payhead_detail][:amount][i],
   #     :month => date)
   #    if @variable_payhead_detail.save
   #      @salary_structure_line_item = SalaryStructureLineItem.find_by_payhead_id_and_salary_structure_id(@variable_payhead_detail.payhead_id, @salary_structure.id)
   #      updated_amount = @salary_structure_line_item.amount += @variable_payhead_detail.amount
   #      @salary_structure_line_item.update_attribute(:amount, updated_amount)
   #      @is_save = true
   #    else
   #      @is_save = false
   #      flash[:error] = "something went wrong"
   #    end
   #   end
   # end
  end

  def add_row
    @salary_structure_line_item = SalaryStructureLineItem.new
    @payheads = @company.payheads.where(:optional => true)
    respond_to do |format|
      format.js
    end
  end

  def update_payroll_execution_detail
     @menu = 'Process payroll'
     @page_name = 'Process payroll'
     year = (params[:month].to_i < @financial_year.start_date.month ? @financial_year.end_date.year : @financial_year.start_date.year)
     date = Date.new(year, params[:month].to_i, 1)
     @users = @company.users
     @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
     @payroll_execution_job = PayrollExecutionJob.find_by_company_id_and_execution_date(@company.id, date..date.months_since(6))
  end
  
  def update_payroll_execution
   year = (params[:month].to_i < @financial_year.start_date.month ? @financial_year.end_date.year : @financial_year.start_date.year)
   date = Date.new(year, params[:month].to_i, 1)
   @users = @company.users
   @accounts = TransactionType.fetch_from_accounts(@company.id, 'contra')
   @payroll_execution_job = PayrollExecutionJob.find_by_company_id_and_execution_date(@company.id, date..date.months_since(6))
   # respond_to do |format|
     if !params[:to_account_id].blank? && !params[:execution_date].blank? && @payroll_execution_job.update_attributes(:account_id => Account.get_account_id(params[:to_account_id], @company.id), :execution_date => params[:execution_date])
        flash[:success] = "Successfully updated..."
        redirect_to "/attendances/show?month=#{params[:month]}"
      else
        flash[:error] = "Fields with star * can't be blank"
        redirect_to :back
     end
   # end
  end

  def finalize
    PayrollFinalisation.perform_async(params[:month].to_i, @company.id)
    redirect_to "/attendances/payroll_finalize?month=#{params[:month]}"
  end

  def payroll_finalize
    year = (params[:month].to_i > Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    payroll_date = Date.new(year, params[:month].to_i, 1)
    @month = params[:month].to_i
    payroll_detail_id = PayrollDetail.find_by_company_id_and_month(@company.id, payroll_date).id
    @payroll_finalizing_check = PayrollExecutionJob.check_payroll_finalised(@company.id, payroll_detail_id)
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end

  def discard
    year = (params[:month].to_i > Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    payroll_date = Date.new(year, params[:month].to_i, 1)
    PayrollDiscard.perform_async(@company.id, payroll_date)
    redirect_to "/attendances/payroll_discard?month=#{params[:month]}"
  end

  def payroll_discard
    year = (params[:month].to_i > Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    payroll_date = Date.new(year, params[:month].to_i, 1)
    @month = params[:month].to_i
    @payroll_discard_check = VariablePayheadDetail.check_payroll_discard(@company.id, payroll_date)
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end

 private

 def menu_title
  @menu = "Process Payroll"
  @page_name ="Process Payroll"
 end
end
