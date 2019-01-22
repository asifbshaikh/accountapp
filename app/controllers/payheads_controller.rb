class PayheadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # layout "payroll"#, :except => [:show]
  # GET /paygrades
  # GET /paygrades.xml
  def index
    @search = @company.payheads.search(params[:search])
    @payheads = @search.page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payheads }
    end
  end

  # GET /paygrades/1
  # GET /paygrades/1.xml
  def show
    @payhead = Payhead.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payhead }
    end
  end

  # GET /paygrades/new
  # GET /paygrades/new.xml
  def new
    @payhead = Payhead.new
      @accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payhead }
    end
  end

  # GET /paygrades/1/edit
  def edit
    @users = User.users_in_company(session[:current_user_id])
    @payhead = @company.payheads.find(params[:id])
    if @payhead.payhead_type =="Earnings"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
    elsif @payhead.payhead_type =="Standard deductions"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'stddeductionacc')
    elsif @payhead.payhead_type =="Other deductions"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'otherdeductionacc')
    end
  end

  # POST /paygrades
  # POST /paygrades.xml
  def create
    @payhead = Payhead.new(params[:payhead])
    @payhead.company_id = @company.id
    @payhead.defined_by = session[:current_user_id]
    logger.info"+++++++++++ account_id=#{@payhead.account_id}"
    respond_to do |format|
      if @payhead.save
        @payhead.register_user_action(request.remote_ip, "created", @current_user.branch_id)
        format.html { redirect_to(payheads_path, :notice => 'Payhead successfully created.') }
        format.xml  { render :xml => @payhead, :status => :created, :location => @payhead }
      else
        if @payhead.payhead_type=="Earnings"
          @accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
        elsif @payhead.payhead_type=="Standard deductions"
          @accounts = TransactionType.fetch_to_accounts(@company.id, 'stddeductionacc')
        elsif @payhead.payhead_type=="Other deductions"
          @accounts = TransactionType.fetch_to_accounts(@company.id, 'otherdeductionacc')
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @payhead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /paygrades/1
  # PUT /paygrades/1.xml
  def update
    @payhead = Payhead.find(params[:id])
    @payhead.account_id = Account.get_account_id(params[:account_id], @company.id)
    if @payhead.payhead_type =="Earnings"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
     logger.info"@@@ ear acc = #{@accounts.count}"
    elsif @payhead.payhead_type =="Standard deductions"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'stddeductionacc')
     logger.info"@@@ str ded acc = #{@accounts.count}"
    elsif @payhead.payhead_type =="Other deductions"
     @accounts = TransactionType.fetch_to_accounts(@company.id, 'otherdeductionacc')
     logger.info"@@@ otr ded acc = #{@accounts.count}"
    end
    respond_to do |format|
      if @payhead.update_attributes(params[:payhead])
        @payhead.register_user_action(request.remote_ip, "updated", @current_user.branch_id)
        format.html { redirect_to(payheads_path, :notice => 'Payhead was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payhead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /paygrades/1
  # DELETE /paygrades/1.xml
  def destroy
    @payhead = Payhead.find(params[:id])
    # @salary_structure_line_items = SalaryStructureLineItem.where(:payhead_id =>@payhead.id)
    # @salaries = Salaries.where(:payhead_id => @payhead.id)
    if @payhead.has_records?
     flash[:error] = "This payhead will not be deleted because it is either used in some salary structures or salary generated earlier."
    else
    @payhead.destroy
    flash[:success] = "Payhead successfully deleted"
    @payhead.register_user_action(request.remote_ip, "deleted", @current_user.branch_id)
   end
    respond_to do |format|
      format.html { redirect_to(payheads_path) }
      format.xml  { head :ok }
    end
  end

 def payroll_account
  if params[:payhead_type]=="Earnings"
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
  elsif params[:payhead_type]=="Standard deductions"
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'stddeductionacc')
  elsif params[:payhead_type]=="Other deductions"
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'otherdeductionacc')
  end
 end

 private
 def record_not_found
   flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
   redirect_to :action=> :index
 end
end
