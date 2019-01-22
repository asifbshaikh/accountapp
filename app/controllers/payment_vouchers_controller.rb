class PaymentVouchersController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /payment_vouchers
  # GET /payment_vouchers.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => PaymentVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  def deleted_payment_voucher
    @search = @company.payment_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @payment_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
     respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payment_vouchers }
    end
  end

  # GET /payment_vouchers/1
  # GET /payment_vouchers/1.xml
  def show
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf = PaymentVoucherPdf.new(@view_context, @payment_voucher)
        send_data(pdf.render, :filename=>"#{@payment_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf")
        prawnto :filename => "#{@payment_voucher.voucher_number}.pdf"
      end
    end
  end

  # GET /payment_vouchers/new
  # GET /payment_vouchers/new.xml
  def new
    @payment_voucher = PaymentVoucher.new_payment(params, @company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    # @vendor_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
    @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
    @voucher_setting=VoucherSetting.by_voucher_type(7, @company.id).first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment_voucher }
    end
  end

  # GET /payment_vouchers/1/edit
  def edit
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    @payment_detail = @payment_voucher.payment_detail
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
    @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
    @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
    @payment_voucher.old_file_size = @payment_voucher.uploaded_file_file_size
    @voucher_setting=VoucherSetting.by_voucher_type(7, @company.id).first
  end

  # POST /payment_vouchers
  # POST /payment_vouchers.xml
  # [FIXME] This entire method need to be revamped. Most of the code can be moved into the model.
  def create
    @payment_voucher = PaymentVoucher.create_payment(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @payment_voucher.valid?
        @payment_voucher.save_and_manage_status(request.remote_ip)
        format.html { redirect_to(@payment_voucher, :notice => 'Payment voucher has been successfully created.') }
        format.js {render "add_payment"}
        format.xml  { render :xml => @payment_voucher, :status => :created, :location => @payment_voucher }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
        if @payment_voucher.other_payment?
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
        else
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        end
        if @payment_voucher.against_vouchers? && !@payment_voucher.to_account.blank?
          purchases=@company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          purchases=purchases.where("id not in(?)",@payment_voucher.purchases_payments.map { |e| e.purchase_id }) unless @payment_voucher.purchases_payments.blank?
          purchases.map { |purchase| @payment_voucher.purchases_payments.build(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
          expenses=@company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          expenses=expenses.where("id not in(?)",@payment_voucher.expenses_payments.map { |e| e.expense_id }) unless @payment_voucher.expenses_payments.blank?
          expenses.map{ |expense| @payment_voucher.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
        end

        @payment_detail = PaymentVoucher.fetch_payment_details(params)
        @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
        @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(7, @company.id).first
        format.html { render :action => "new" }
        format.js {render "add_payment"}
        format.xml  { render :xml => @payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payment_vouchers/1
  # PUT /payment_vouchers/1.xml
  def update
    @payment_voucher = PaymentVoucher.update_payment(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @payment_voucher.valid?
        @payment_voucher.update_and_manage_status(request.remote_ip)
        format.html { redirect_to(@payment_voucher, :notice => 'Payment voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
        if @payment_voucher.other_payment?
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
        else
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        end
        @payment_detail = @payment_voucher.payment_detail
        @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
        @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(7, @company.id).first
        if !params[:back_action].blank? && params[:back_action]=="allocate"
          # purchases=@company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          # @purchases_payments=purchases.map { |purchase| PurchasesPayment.new(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil) if @payment_voucher.purchases_payments.exists?(:purchase_id=> purchase.id) }
          # expenses=@company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          # @expenses_payments=expenses.map{ |expense| ExpensesPayment.new(:expense_id=>expense.id, :tds_amount=> nil, :amount=>nil) if @payment_voucher.expenses_payments.where(:expense_id=>expense.id).blank?}

          purchases=@company.purchases.where("id not in(?)",@payment_voucher.purchases_payments.map { |e| e.purchase_id }).by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          purchases.map { |purchase| @payment_voucher.purchases_payments.build(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
          expenses=@company.expenses.where("id not in(?)",@payment_voucher.expenses_payments.map { |e| e.expense_id }).by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@payment_voucher.to_account_id).by_currency(@payment_voucher.to_account.get_currency_id)
          expenses.map{ |expense| @payment_voucher.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
          format.html { render :action => "allocate" }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @payment_voucher.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

   #soft delete payment_voucher
  def destroy
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    @payment_voucher.fin_year = @financial_year.year.name
    respond_to do |format|
      if @payment_voucher.destroy_and_manage_voucher_status
        @payment_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to(payment_vouchers_url, :notice => "payment voucher has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.payment_vouchers.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @payment_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
        flash[:error] = "The payment voucher was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end
#restore purchase
  def restore_payment_voucher
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    @payment_voucher.fin_year = @financial_year.year.name
    respond_to do |format|
      if @payment_voucher.restore(@current_user.id)
        @payment_voucher.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(payment_vouchers_url, :notice => "payment voucher has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.payment_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @payment_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
        flash[:error] = "The payment voucher was not restored due to an error."
        format.html { render :action => "deleted_payment_voucher" }
        format.xml  { render :xml => @payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete payment_voucher
  def permanent_delete_payment_voucher
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    respond_to do |format|
      if @payment_voucher.destroy
        @payment_voucher.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(payment_vouchers_deleted_payment_voucher_url, :notice => "Payment voucher has been permanently deleted") }
        format.xml  { head :ok }
      else
        @search = @company.payment_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @payment_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
        flash[:error] = "The payment voucher was not deleted due to an error."
        format.html { render :action => "deleted_payment_voucher" }
        format.xml  { render :xml => @payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end


  #this action will let the users download the files (after a simple authorization check)
  def get
    @payment_voucher = @company.payment_vouchers.find_by_id(params[:id])
    if @payment_voucher
      send_file @payment_voucher.uploaded_file.path, :type => @payment_voucher.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to payment_vouchers_path
    end
  end
   #method for partial.js(ajax)
  def payment_mode
  end

  def add_account
    @data_account = nil
    if params[:transaction_type] == 'paid_from'
      @account_heads = AccountHead.get_payment_from_heads(@company.id)
      @data_account = 'from_account_auto_complete'
    else
      @account_heads = AccountHead.get_payment_to_heads(@company.id)
      @data_account = 'to_account_auto_complete'
    end
  end

   def account_partial
    @account_head = AccountHead.find(params[:account_head_id]) unless params[:account_head_id].blank?
  end

  def allocate
    @payment_voucher = @company.payment_vouchers.find(params[:id])
    vendor=@company.accounts.find(@payment_voucher.to_account_id)
    purchases=@company.purchases.not_in(@payment_voucher.purchases).by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(vendor.id).by_currency(vendor.get_currency_id)
    purchases.map { |purchase| @payment_voucher.purchases_payments.build(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
    expenses=@company.expenses.not_in(@payment_voucher.expenses).by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(vendor.id).by_currency(vendor.get_currency_id)
    expenses.map{ |expense| @payment_voucher.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
  end
  
  def vendor_unpaid_vouchers
    vendor=@company.accounts.find params[:account_id]
    purchases=@company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(vendor.id).by_currency(vendor.get_currency_id)
    @purchases_payments = purchases.map { |purchase| PurchasesPayment.new(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
    expenses=@company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(vendor.id).by_currency(vendor.get_currency_id)
    @expenses_payments=expenses.map{ |expense| ExpensesPayment.new(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
  end

  def load_form
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    if params[:form_type]=="other_payment"
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
    else
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    end
  end
  # def search_purchase
  #   @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
  #   @vendor_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
  #   srange = nil
  #   erange = nil
  #   if !params[:purchase_amount].blank?
  #     if params[:purchase_amount].to_i == 1
  #       srange = 0
  #       erange = 5000
  #     elsif params[:purchase_amount].to_i == 2
  #       srange = 5000
  #       erange = 50000
  #     elsif params[:purchase_amount].to_i == 3
  #       srange = 50000
  #       erange = 100000
  #     elsif params[:purchase_amount].to_i == 4
  #       srange = 100000
  #     end
  #   end
  #   vendor = @company.accounts.find_by_id(params[:account_id])
  #   if vendor.blank?
  #     @pur_nos = @company.purchases.where(:status_id=>false, :deleted => false)
  #   else
  #     @pur_nos = @company.purchases.where(:status_id=>false, :deleted => false, :account_id=>vendor.id)
  #   end
  #   @pur_nos1= @pur_nos
  #   unless srange.blank? || erange.blank?
  #     @pur_nos = []
  #     @pur_nos1.each do |pur|
  #       if pur.amount >= srange && pur.amount <= erange
  #         @pur_nos<<pur
  #       end
  #     end
  #   end
  #   if !srange.blank? && erange.blank?
  #     @pur_nos = []
  #     @pur_nos1.each do |pur|
  #       if pur.amount >= srange
  #         @pur_nos<<pur
  #       end
  #     end
  #   end
  #   respond_to do |format|
  #     format.js
  #   end
  # end

 private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
