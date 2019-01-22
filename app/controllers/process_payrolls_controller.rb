class ProcessPayrollsController < ApplicationController
layout 'payroll'
  # GET /process_payrolls
  # GET /process_payrolls.xml
  def index
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @process_payrolls = ProcessPayroll.where(:company_id => @company.id, :month => params[:month].to_s)
    @users = @company.users


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_payrolls }
    end
  end
  
  def month_view
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
  end

  # GET /process_payrolls/1
  # GET /process_payrolls/1.xml
  def show
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @process_payroll = ProcessPayroll.find(params[:id])
    @users = @company.users
    #@process_payrolls = ProcessPayroll.find_all_by_company_id_and_user_id_and_month(@company.id, params[:user_id], params[:month])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_payroll }
    end
  end

  # GET /process_payrolls/new
  # GET /process_payrolls/new.xml
  def new
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @process_payroll = ProcessPayroll.new
    @users = @company.users
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_payroll }
    end
  end

  # GET /process_payrolls/1/edit
  def edit
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @process_payroll = ProcessPayroll.find(params[:id])
    @users = @company.users
  end

  # POST /process_payrolls
  # POST /process_payrolls.xml
  def create
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @users = @company.users

    respond_to do |format|
    @users.count.times do |i|
      if !params[:process_payroll][:attendance][i].blank? && @process_payroll = ProcessPayroll.new(
                                                               :user_id => params[:process_payroll][:user_id][i], 
                                                               :company_id => @company.id, 
                                                               :attendance => params[:process_payroll][:attendance][i], 
                                                               :month => params[:process_payroll][:month])

         @process_payroll.save
        
       format.html { redirect_to "/process_payrolls/?company_id=#{@company.id}&month=#{@process_payroll.month}",{ :notice => "Process payroll was created successfully."} }
        format.xml  { render :xml => @process_payrolls, :status => :created, :location => @process_payrolls }
     else
       format.html { render :action => "new" }
       format.xml  { render :xml => @process_payroll.errors, :status => :unprocessable_entity }
     end
    end
  end
end
  # PUT /process_payrolls/1
  # PUT /process_payrolls/1.xml
  def update
    @menu = 'Process payroll'
    @page_name = 'Process payroll'
    @process_payroll = ProcessPayroll.find(params[:id])

    respond_to do |format|
      if @process_payroll.update_attributes(params[:process_payroll])
        format.html { redirect_to(@process_payroll, :notice => 'Process payroll was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_payroll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_payrolls/1 
  # DELETE /process_payrolls/1.xml
  def destroy
    @process_payroll = ProcessPayroll.find(params[:id])
    @process_payroll.destroy

    respond_to do |format|
      format.html { redirect_to(process_payrolls_url) }
      format.xml  { head :ok }
    end
  end
  def request_payroll
   if user = @company.users.first
    Email.payroll_request(user, @company).deliver
    redirect_to ("/process_payrolls/month_view")
    flash[:success] = 'Email has been send successfully.' 
   else
     flash[:error]= "Something went wrong." 
   end
  end
end
