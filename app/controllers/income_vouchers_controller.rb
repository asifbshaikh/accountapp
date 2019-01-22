class IncomeVouchersController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /income_vouchers
  # GET /income_vouchers.xml
  def index
     # @receipt_vouchers = @company.receipt_vouchers.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).order("voucher_date DESC").page(params[:page]).per(20)
     #  @income_vouchers = @company.income_vouchers.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).order("income_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @income_vouchers }
      format.json { render :json => IncomeVouchersDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_other_income
    @search= @company.income_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @income_vouchers = @search.order("income_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @income_vouchers }
    end
  end

  # GET /income_vouchers/1
  # GET /income_vouchers/1.xml
  def show
    @income_voucher = IncomeVoucher.find(params[:id])
    @currency = @company.currency_code
    respond_to do |format|
      format.html # show.html.erb
      format.pdf {render :layout => false}
      format.xml  { render :xml => @income_voucher }
      prawnto :filename => "#{@income_voucher.voucher_number}.pdf"
    end
  end

  # GET /income_vouchers/new
  # GET /income_vouchers/new.xml
  def new
    @income_voucher = IncomeVoucher.new_income(@company)
    @invoices = @company.invoices
    @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
    @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

    @receipt_voucher = ReceiptVoucher.new_receipt(params, @company)
    @projects = @company.projects.where(:status => false)
    # @invoices = @company.invoices.where("invoice_status_id = ? and deleted = ? and invoice_date <= ?",0,false,@financial_year.end_date)
    @invoices = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).by_status(0)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    @inv_nos = Invoice.where(:company_id => @company.id, :deleted => false, :invoice_date => @financial_year.start_date..@financial_year.end_date, :invoice_status_id=>0)
    @customer_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @income_voucher }
    end
  end

  # GET /income_vouchers/1/edit
  def edit
    @income_voucher = IncomeVoucher.find(params[:id])
    @payment_detail = @income_voucher.payment_detail
    # @invoices = @company.invoices
    @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
    @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
  end

  # POST /income_vouchers
  # POST /income_vouchers.xml
  def create
    @invoices = @company.invoices
    @income_voucher = IncomeVoucher.create_income(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @income_voucher.valid?
        @income_voucher.save_with_ledgers
        if !params[:transaction_id].blank? && !params[:account_id].blank?
         transaction = Ledger.where(:account_id => params[:account_id])
         bank_statement_line_item = BankStatementLineItem.find(params[:transaction_id])
         transaction.last.update_attributes(:reconcilation_status => true, :reconcilation_date => Time.zone.now.to_date)
         bank_statement_line_item.update_attributes(:status => 1, :ledger_id => transaction.last.id)
        end
        @income_voucher.register_user_action(request.remote_ip, 'created')
        format.js {render "bank_statements/create_other_income"}
        format.html { redirect_to(receipt_vouchers_path, :notice => 'Income voucher was successfully created.') }
        format.xml  { render :xml => @income_voucher, :status => :created, :location => @income_voucher }
      else
        @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
        @payment_detail = IncomeVoucher.fetch_payment_details(params)
        @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

         @projects = @company.projects.where(:status => false)
        @invoices = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).by_status(0)
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
         @receipt_voucher = ReceiptVoucher.new_receipt(params, @company, @current_user, @from_accounts.first)
        @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
        @customer_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        format.js {render "bank_statements/create_other_income"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @income_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /income_vouchers/1
  # PUT /income_vouchers/1.xml
  def update
    @income_voucher = IncomeVoucher.update_income(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      @income_voucher.update_attributes(params[:income_voucher])
      if @income_voucher.valid?
        @income_voucher.update_and_post_ledgers
        @income_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(receipt_vouchers_path, :notice => 'Income voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
        @payment_detail = @income_voucher.payment_detail
        @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @income_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  #soft delete other income voucher
  def destroy
    @income_voucher = IncomeVoucher.find(params[:id])
    @income_voucher.fin_year = @financial_year.year.name
    respond_to do |format|
      if @income_voucher.destroy
        @income_voucher.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(receipt_vouchers_url, :notice => "other income has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search= @company.income_vouchers.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @income_vouchers = @search.order("income_date DESC").page(params[:page]).per(20)
        flash[:error] = "The other income voucher was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @income_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  def restore_other_income
    @income_voucher = IncomeVoucher.find(params[:id])
    @income_voucher.fin_year = @financial_year.year.name
    respond_to do |format|
      if @income_voucher.restore(@current_user.id)
        @income_voucher.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(income_vouchers_url, :notice => "other income has been successfully restored") }
        format.xml  { head :ok }
      else
        @search= @company.income_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @income_vouchers = @search.order("income_date DESC").page(params[:page]).per(20)
        flash[:error] = "The other income was not restored due to an error."
        format.html { render :action => "deleted_other_income" }
        format.xml  { render :xml => @income_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete other income
  def permanent_delete_other_income
    @income_voucher = IncomeVoucher.find(params[:id])
    respond_to do |format|
      if @income_voucher.destroy
        @income_voucher.register_user_action(request.remote_ip, 'deleted')
    		format.html { redirect_to(income_vouchers_deleted_other_income_url, :notice => "Other income has been permanently deleted") }
		    format.xml  { head :ok }
      else
        @search= @company.income_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @income_vouchers = @search.order("income_date DESC").page(params[:page]).per(20)
        flash[:error] = "The other income voucher was not deleted due to an error."
        format.html { render :action => "deleted_other_income" }
        format.xml  { render :xml => @income_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end
 #method for partial.js(ajax)
  def payment_detail
  end
  def payment_mode_edit
   @payment_mode = PaymentMode.find_by_voucher_id(params[:voucher_id])
  end

  def add_account
    @data_account = nil
    if params[:transaction_type] == 'receipt'
  	  @account_heads = AccountHead.get_receipt_from_heads(@company.id)
  	  @data_account = 'from_account_auto_complete'
  	else
  	  @account_heads = AccountHead.get_contra_to_heads(@company.id)
  	  @data_account = 'to_account_auto_complete'
  	end
	end

  def menu_title
    @menu = 'Income'
    @page_name = 'Other Income'
  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :controller => :receipt_vouchers ,:action=> :index
  end

end
