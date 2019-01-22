class ExpensesController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /expenses
  # GET /expenses.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  {render :json => ExpenseDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  def deleted_expense
    @search = @company.expenses.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @expenses = @search.order("expense_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expenses }
    end
  end
  # GET /expenses/1
  # GET /expenses/1.xml
  def show
    @expense = @company.expenses.find(params[:id])
    @projects = @company.projects.where(:status => false)
    @expense_line_items = @expense.expense_line_items
    @tax_line_items = @expense.tax_line_items.group(:account_id)
    @payment_vouchers = @expense.expenses_payments
    @payment_voucher = PaymentVoucher.new_payment(params, @company)
    @payment_voucher.expense_id = @expense.id
    @payment_voucher.to_account_id = @expense.account_id
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=ExpensePdf.new(view_context, @expense)
        send_data pdf.render, :filename=>"#{@expense.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.xml  { render :xml => @expense }
      prawnto :filename => "#{@expense.voucher_number}.pdf"
    end
  end

  # GET /expenses/new
  # GET /expenses/new.xml
  def new
    @projects = @company.projects.where(:status => false)
    @expense = Expense.new_expense(@company)
    @expense.project_id=params[:project_id] if params[:project_id].present?
    @vendor_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @payment_account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @voucher_setting=VoucherSetting.by_voucher_type(4, @company.id).first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expense }
    end
  end

# action to copy expense into new
  def copy_expense
    @projects = @company.projects.where(:status => false)
    @old_expense = @company.expenses.find_by_id(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
    @vendor_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @voucher_setting=VoucherSetting.by_voucher_type(4, @company.id).first
    @expense = @old_expense.dup

    @old_expense.expense_line_items.each do |line_item|
      expense_line_item=line_item.dup
      line_item.expense_taxes.each do |tax|
        expense_line_item.expense_taxes<<tax.dup
      end
      (2-expense_line_item.expense_taxes.size).times{ expense_line_item.expense_taxes.build }
      @expense.expense_line_items<<expense_line_item
    end

    @expense.expense_date = Time.zone.now.to_date
    @expense.created_by = @current_user.id
    @expense.voucher_number = VoucherSetting.next_expense_number(@company)

    @payment_account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)

    respond_to do |format|
      format.html {render :action=> "new"}
    end
  end


  # GET /expenses/1/edit
  def edit
    @expense = @company.expenses.find(params[:id])
    @expense.expense_line_items.each do |line_item|
      (2-line_item.expense_taxes.size).times{line_item.expense_taxes.build}
    end
    @projects = @company.projects.where(:status => false)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
    @vendor_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @expense.old_file_size = @expense.uploaded_file_file_size

    @payment_account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @voucher_setting=VoucherSetting.by_voucher_type(4, @company.id).first
  end

  # POST /expenses
  # POST /expenses.xml
  def create
    @expense = Expense.create_expense(params, @company, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @expense.valid?
         @expense.save_with_ledgers
         if !params[:transaction_id].blank? && !params[:from_account_id].blank?
         transaction = Ledger.where(:account_id => params[:from_account_id])
         bank_statement_line_item = BankStatementLineItem.find(params[:transaction_id])
         transaction.last.update_attributes(:reconcilation_status => true, :reconcilation_date => Time.zone.now.to_date)
         bank_statement_line_item.update_attributes(:status => 1, :ledger_id => transaction.last.id)
        end
         @expense.register_user_action(request.remote_ip, 'created')
        format.js {render "bank_statements/create_expense"}
        format.html { redirect_to(@expense, :notice => 'Expense was successfully created.') }
        format.xml  { render :xml => @expense, :status => :created, :location => @expense }
      else
        @projects = @company.projects.where(:status => false)
        @expense.expense_line_items.each do |line_item|
          (2-line_item.expense_taxes.size).times{line_item.expense_taxes.build}
        end
        @vendor_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')

        @payment_account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
        @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(4, @company.id).first
        format.js {render "bank_statements/create_expense"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expenses/1
  # PUT /expenses/1.xml
  def update
    @expense = Expense.update_expense(params, @company, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @expense.valid?
        @expense.save
        @expense.update_and_post_ledgers
        @expense.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@expense, :notice =>  'Expense was successfully updated.') }
        format.xml  { head :ok }
      else
        @projects = @company.projects.where(:status => false)
        @expense.expense_line_items.each do |line_item|
          (2-line_item.expense_taxes.size).times{line_item.expense_taxes.build}
        end
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
        @vendor_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')

        @payment_account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
        @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(4, @company.id).first
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

 def update_itc_details

    @expense_line_item = ExpenseLineItem.find_by_id(params[:id])
    if(params[:eligibility]=="Input")
      eligibility = "ip"
    elsif (params[:eligibility]=="Capital Good")
      eligibility = "cp"
    elsif (params[:eligibility]=="Input Service")
      eligibility = "is"
    else
      eligibility = "no"
    end
    @expense_line_item.update_attributes(:eligibility => eligibility, :input_tax_percentage => params[:input_tax_percentage] )
  
respond_to do |format|
      format.html { render :action => "show", :notice => 'itc details update successfully.' }
        format.js { render "expense_itc_update" }
    end
  end

 #soft delete expense
  def destroy
    @expense = @company.expenses.find(params[:id])
    @expense.fin_year = @financial_year.year.name
    respond_to do |format|
      if @expense.delete_and_manage_payment_if_credit_expense
        @expense.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to(expenses_url, :notice => "Expense has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @expenses = @search.order("expense_date DESC").page(params[:page]).per(20)
        flash[:error] = "The expense was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  #restore expense
  def restore_expense
    @expense = @company.expenses.find(params[:id])
    @expense.fin_year = @financial_year.year.name
    respond_to do |format|
      if @expense.restore(@current_user.id)
        @expense.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(expenses_url, :notice => "Expense has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.expenses.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @expenses = @search.order("expense_date DESC").page(params[:page]).per(20)
        flash[:error] = "The expense was not restored due to an error."
        format.html { render :action => "deleted_expense" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  def expenses_report
    @start_date = params[:start_date].blank? ? (@company.activation_date) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @expenses = Expense.where("company_id=? and expense_date BETWEEN ? AND ? ", @company.id, @start_date, @end_date)
    # prawnto :filename => "#{@company.label.warehouse_label}"+" "+ "report.pdf"
  end

  #Hard delete expense
  def permanent_delete_expense
    @expense = @company.expenses.find(params[:id])

    respond_to do |format|
    if @expense.destroy
      @expense.register_user_action(request.remote_ip, 'deleted')
		format.html { redirect_to(expenses_deleted_expense_url, :notice => "Expense has been permanently deleted") }
		format.xml  { head :ok }
      else
        @search = @company.expenses.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @expenses = @search.order("expense_date DESC").page(params[:page]).per(20)
        flash[:error] = "The expense was not deleted due to an error."
        format.html { render :action => "deleted_expense" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # add_row /add_row ajax call
  def add_row
    @expense_line_item = ExpenseLineItem.new
    2.times{ @expense_line_item.expense_taxes.build }
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = ExpenseLineItem.new
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end
  def remove_tax_item
  end

  #this action will let the users download the files (after a simple authorization check)
  def get
    @expense = @company.expenses.find_by_id(params[:id])
    if @expense
      send_file @expense.uploaded_file.path, :type => @expense.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to expenses_path
    end
  end

  def add_account
    @data_account = nil
    if params[:transaction_type] == 'payment'
      @account_heads = AccountHead.get_expense_acc_from_heads(@company.id)
      @data_account = 'payment'
    elsif params[:transaction_type] == 'expense'
      @account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
      @data_account = "expense"
    elsif params[:transaction_type] == 'tax'
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
	  end
  end
  def account_select
    if params[:option]=='cash'
      @accounts = TransactionType.fetch_from_accounts(@company.id, 'expenseacc')
    else
      @accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    end
  end
 private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
