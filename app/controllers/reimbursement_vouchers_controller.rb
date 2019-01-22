class ReimbursementVouchersController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /receipt_vouchers
  # GET /receipt_vouchers.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => ReimbursementVouchersDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  def deleted_receipt_voucher
    @search = @company.receipt_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @receipt_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @receipt_vouchers}
    end
  end

  # GET /receipt_vouchers/1
  # GET /receipt_vouchers/1.xml
  def show
    @reimbursement_voucher = @company.reimbursement_vouchers.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reimbursement_voucher }
    end
  end

  # GET /receipt_vouchers/new
  # GET /receipt_vouchers/new.xml
  def new
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @reimbursement_voucher = ReimbursementVoucher.new_voucher(params, @company, @current_user, @from_accounts.first)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    @payment_detail = PaymentDetail.new
    @reimbursement_notes_for_account = @company.reimbursement_notes.where(:submitted => false, :from_account_id => Account.where(:customer_id => @company.customers.order(:name).first))
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reimbursement_voucher }
    end
  end

  # GET /receipt_vouchers/1/edit
  def edit
    @reimbursement_voucher = @company.reimbursement_vouchers.find(params[:id])
    @receipt_detail = @reimbursement_voucher.payment_detail
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 2)
    @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    # @reimbursement_notes_for_account = @company.reimbursement_notes.where(:from_account_id => @reimbursement_voucher.from_account_id)
    @reimbursement_notes_for_account = @reimbursement_voucher.reimbursement_notes
    @reimbursement_notes_for_account << @company.reimbursement_notes.where(:submitted => false, :deleted => false)
  end

  # POST /receipt_vouchers
  # POST /receipt_vouchers.xml
  def create
    @reimbursement_voucher = ReimbursementVoucher.create_voucher(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @reimbursement_voucher.valid?
        @reimbursement_voucher.save_and_make_relation_with_reimbursement_notes
        @reimbursement_voucher.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@reimbursement_voucher, :notice => 'Reimbursement receipt was successfully created.') }
        format.xml  { render :xml => @reimbursement_voucher, :status => :created, :location => @reimbursement_voucher }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
        @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
        @payment_detail = PaymentDetail.new
        format.html { render :action => "new" }
        format.xml  { render :xml => @reimbursement_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end
  # PUT /reimbursement_vouchers/1
  # PUT /reimbursement_vouchers/1.xml
  def update
    @reimbursement_voucher = ReimbursementVoucher.update_voucher(params, @company.id, @current_user, @financial_year.year.name)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    respond_to do |format|
      if @reimbursement_voucher.valid?
        @reimbursement_voucher.update_and_remake_relation_with_reimbursement_notes
        @reimbursement_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@reimbursement_voucher, :notice => 'Reimbursement receipt was successfully updated.') }
        format.xml  { head :ok }
      else
        @receipt_detail = @reimbursement_voucher.payment_detail
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
        @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @reimbursement_notes_for_account = @company.reimbursement_notes.where(:from_account_id => @reimbursement_voucher.from_account_id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @receipt_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  #soft delete vouchers
  def destroy
    @reimbursement_voucher = @company.reimbursement_vouchers.find(params[:id])
    ActiveRecord::Base.transaction do
      @reimbursement_voucher.delete(@current_user)
    end
    respond_to do |format|
      @reimbursement_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')
      format.html { redirect_to(reimbursement_vouchers_url, :notice => "Reimbursement receipt has been successfully deleted") }
    end
  end

  def get_reimbursement_notes_for_account
    @reimbursement_notes_for_account = @company.reimbursement_notes.where(:submitted => false, :deleted => false, :from_account_id => params[:account_id])
    respond_to do |format|
      format.js
    end
  end

  def payment_mode
  end

  def add_deposit_to_account
    @account_heads = AccountHead.get_receipt_to_heads(@company.id)
  end
  def account_partial
    @account_head = AccountHead.find(params[:account_head_id]) unless params[:account_head_id].blank?
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
end
