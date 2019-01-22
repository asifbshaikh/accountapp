class SalaryStructuresController < ApplicationController
  # layout "payroll"
  # GET /salary_structures
  # GET /salary_structures.xml
  def index
    @users = @company.users
    @search = @company.salary_structures.search(params[:search])
    @salary_structures = @search.page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @salary_structures }
    end
  end

  # GET /salary_structures/1
  # GET /salary_structures/1.xml
  def show
    @salary_structure = SalaryStructure.find(params[:id])
    @salary_structure_histories = @company.salary_structure_histories.where(:for_employee => @salary_structure.for_employee)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @salary_structure }
    end
  end

  # GET /salary_structures/new
  # GET /salary_structures/new.xml
  def new
    @user = User.find_by_id(params[:user_id])
    @payheads = @company.payheads.where(:optional => false)
    @salary_structure = SalaryStructure.new
    @salary_structure.for_employee = params[:user_id]
    # @salary_structure.salary_structure_line_items.build 
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @salary_structure }
    end
  end
  # action to make clone of salary structure
  def copy_salary_structure
   @users = @company.users.without_salary_structure
   @payheads = @company.payheads.where(:optional => false)
   @old_salary_structure = SalaryStructure.find_by_id(params[:id])
   @salary_structure = SalaryStructure.new
   @salary_structure.company_id = @old_salary_structure.company_id
   @salary_structure.created_by = @current_user.id
   
   @old_salary_structure.salary_structure_line_items.each do |line_item|
    salary_structure_line_item = SalaryStructureLineItem.new(
       :payhead_id => line_item.payhead_id,
       :amount => line_item.amount
      ) 
    @salary_structure.salary_structure_line_items << salary_structure_line_item
   end  
  end

  # GET /salary_structures/1/edit
  def edit
    @user= User.find_by_id(params[:user_id])
    @payheads = @company.payheads
    @salary_structure = SalaryStructure.find_by_company_id_and_for_employee(@company.id, @user.id)
  end

  # POST /salary_structures
  # POST /salary_structures.xml
  def create
    @salary_structure = SalaryStructure.new(params[:salary_structure])
    @user = User.find_by_id(params[:user_id])
    @payheads = @company.payheads.exclude_taken(@salary_structure)
    # @var_payheads = @company.payheads.where(:optional => true)
    @salary_structure.company_id = @company.id
    @salary_structure.created_by = @current_user.id
    respond_to do |format|
      if @salary_structure.valid?
        @salary_structure.save_with_variable_payheads
        last_salary_structure = SalaryStructure.order("effective_from_date DESC").where("effective_from_date < ? and company_id=? and for_employee=?", @salary_structure.effective_from_date, @company.id, @user.id).first
        unless last_salary_structure.blank?
          last_salary_structure.update_attribute(:valid_till_date, (@salary_structure.effective_from_date - 1.days))
        end
        @salary_structure.register_user_action(request.remote_ip, "created", @current_user.branch_id)
        flash[:success]= "Salary structure successfully created."
        format.html { redirect_to("/users/salary_details?id=#{@salary_structure.for_employee}") }
        format.xml  { render :xml => @salary_structure, :status => :created, :location => @salary_structure }
      else
        # @payheads = @company.payheads.exclude_taken(@salary_structure)
        format.html { render :action => "new", :user_id=>"#{@user.id}" }
        format.xml  { render :xml => @salary_structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /salary_structures/1
  # PUT /salary_structures/1.xml
  def update
    @salary_structure = SalaryStructure.find_by_id(params[:id])
    @payheads = @company.payheads
    @salary_structure.assign_attributes(params[:salary_structure])
    last_salary_structure = SalaryStructure.order("effective_from_date DESC").where("effective_from_date < ? and company_id=? and for_employee=?", @salary_structure.effective_from_date, @company.id, @salary_structure.for_employee).first
    exist_salary_structure = SalaryStructure.where(:company_id=>@company.id, :for_employee=>@salary_structure.for_employee, :effective_from_date=>@salary_structure.effective_from_date).first
    if exist_salary_structure.blank? || exist_salary_structure.effective_from_date != @salary_structure.effective_from_date
      @salary_structure = SalaryStructure.create_salary_structure(@salary_structure, @company.id, @current_user.id)
    end
    respond_to do |format|
      if @salary_structure.valid?
        if @salary_structure.new_record?
          last_salary_structure.update_attribute(:valid_till_date, (@salary_structure.effective_from_date - 1.days))
        end
        @salary_structure.save
        @salary_structure.create_history(@salary_structure, @current_user)
        @salary_structure.register_user_action(request.remote_ip, "updated", @current_user.branch_id)
        format.html { redirect_to("/users/salary_details?id=#{@salary_structure.for_employee}", :notice => 'Salary structure was successfully updated.') }
        format.xml  { head :ok }
      else
        @payheads = @company.payheads.exclude_taken(@salary_structure)
        @user = User.find_by_id(@salary_structure.for_employee)
        if @salary_structure.new_record?
          format.html { render :action => "new", :locals=> {:user_id=>@salary_structure.for_employee}}
        else
          format.html { render :action => "edit" }
        end
        format.xml  { render :xml => @salary_structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /salary_structures/1
  # DELETE /salary_structures/1.xml
  def destroy
    @salary_structure = SalaryStructure.find(params[:id])
    @salary_structure.destroy
    @salary_structure.register_user_action(request.remote_ip, "deleted", @current_user.branch_id)
     respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end
  def remove_line_item
  end
  def add_row
    @salary_structure_line_item = SalaryStructureLineItem.new
    @payheads = @company.payheads.where(:optional => false)
    respond_to do |format|
      format.js
    end
  end

  def add_payhead
    @data_account = nil
    @payhead = Payhead.new
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'payrollacc')
  end
 
  def create_payhead
    @is_save = false
    @payhead = Payhead.new
    @payhead.company_id = @company.id
    @payhead.defined_by = @current_user.id
    @payhead.payhead_name = params[:name]
    @payhead.payhead_type = params[:type]
    @payhead.account_id = params[:account_id]
    @payhead.affect_net_salary = params[:affect_net_salary]
    @payhead.name_appear_in_payslip = params[:payslip_name]
    @payhead.use_of_gratuity = params[:use_of_gratuity]
    @payhead.optional = false
    
    if @payhead.valid? && @payhead.save
         # @account = Account.new
         # @account.name = @payhead.payhead_name
         # @account.company_id = @company.id
         # if @payhead.payhead_type == 'Earnings' 
         #   @account.account_head_id = AccountHead.get_indirect_expense_acc_head(@company).id
         # elsif @payhead.payhead_type == 'Standard deductions'
         #   @account.account_head_id = AccountHead.get_duties_and_taxes_account(@company).id
         # elsif @payhead.payhead_type == 'Other deductions'
         #   @account.account_head_id = AccountHead.get_indirect_income_acc_head(@company).id
         # end
         # if !@account.account_head_id.blank?
         #    sub_account = AccountsController.fetch_account_head(@account.account_head_id, params)
         #    @account.accountable = sub_account
         # end
         # @account.created_by = @current_user.id
         
         # @account.save
        @is_save = true
    else
      @is_save = false
    end
  end
end 
