class PurchaseAdvancesController < ApplicationController
  # GET /purchase_advances
  # GET /purchase_advances.json
  def index
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: PurchaseAdvanceDatatable.new(view_context, @company, @current_user, @financial_year)  }
    end
  end

  # GET /purchase_advances/1
  # GET /purchase_advances/1.json
  def show
    @purchase_advance = PurchaseAdvance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase_advance }
    end
  end

  # GET /purchase_advances/new
  # GET /purchase_advances/new.json
  def new
    
    @purchase_advance = PurchaseAdvance.new_payment(params, @company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    # @vendor_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
    @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
    @voucher_setting=VoucherSetting.by_voucher_type(26, @company.id).first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @purchase_advance }
    end
  end

  # GET /purchase_advances/1/edit
  def editTax exclusive
    @purchase_advance = PurchaseAdvance.find(params[:id])
  end

  # POST /purchase_advances
  # POST /purchase_advances.json
  def create
   
    @purchase_advance = PurchaseAdvance.create_payment(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @purchase_advance.valid?
        @purchase_advance.save_and_manage_status(request.remote_ip)
        format.html { redirect_to(@purchase_advance, :notice => 'Payment voucher has been successfully created.') }
        format.js {render "add_payment"}
        format.xml  { render :xml => @purchase_advance, :status => :created, :location => @purchase_advance }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        if !@purchase_advance.to_account.blank?
          purchases=@company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          purchases=purchases.where("id not in(?)",@purchase_advance.gstr_advance_purchases_payments.map { |e| e.purchase_id }) unless @purchase_advance.gstr_advance_purchases_payments.blank?
          purchases.map { |purchase| @purchase_advance.gstr_advance_purchases_payments.build(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
          # expenses=@company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          # expenses=expenses.where("id not in(?)",@purchase_advance.expenses_payments.map { |e| e.expense_id }) unless @purchase_advance.expenses_payments.blank?
          # expenses.map{ |expense| @purchase_advance.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
        end

        @payment_detail = PurchaseAdvance.fetch_payment_details(params)
        @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
        @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(26, @company.id).first
        format.html { render :action => "new" }
        format.js {render "add_payment"}
        format.xml  { render :xml => @purchase_advance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_advances/1
  # PUT /purchase_advances/1.json
  def update

    @purchase_advance = PurchaseAdvance.update_payment(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @purchase_advance.valid?
        @purchase_advance.update_and_manage_status(request.remote_ip)
        format.html { redirect_to(@purchase_advance, :notice => 'Payment voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
        if @purchase_advance.other_payment?
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
        else
          @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        end
        @payment_detail = @purchase_advance.payment_detail
        @from_account_heads = AccountHead.get_payment_from_heads(@company.id)
        @to_account_heads = AccountHead.get_payment_to_heads(@company.id)
        @voucher_setting=VoucherSetting.by_voucher_type(7, @company.id).first
        if !params[:back_action].blank? && params[:back_action]=="allocate"
          # purchases=@company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          # @gstr_advance_purchases_payments=purchases.map { |purchase| PurchasesPayment.new(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil) if @purchase_advance.gstr_advance_purchases_payments.exists?(:purchase_id=> purchase.id) }
          # expenses=@company.expenses.by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          # @expenses_payments=expenses.map{ |expense| ExpensesPayment.new(:expense_id=>expense.id, :tds_amount=> nil, :amount=>nil) if @purchase_advance.expenses_payments.where(:expense_id=>expense.id).blank?}

          purchases=@company.purchases.where("id not in(?)",@purchase_advance.gstr_advance_purchases_payments.map { |e| e.purchase_id }).by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_vendor(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          purchases.map { |purchase| @purchase_advance.gstr_advance_purchases_payments.build(:purchase_id=>purchase.id, :tds_amount=>nil, :amount=>nil)}
          expenses=@company.expenses.where("id not in(?)",@purchase_advance.expenses_payments.map { |e| e.expense_id }).by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(@purchase_advance.to_account_id).by_currency(@purchase_advance.to_account.get_currency_id)
          expenses.map{ |expense| @purchase_advance.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
          format.html { render :action => "allocate" }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @purchase_advance.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /purchase_advances/1
  # DELETE /purchase_advances/1.json
  def destroy
    @purchase_advance = PurchaseAdvance.find(params[:id])
    @purchase_advance.destroy

    respond_to do |format|
      format.html { redirect_to purchase_advances_url }
      format.json { head :ok }
    end
  end

  def allocate
    @purchase_advance = @company.purchase_advance.find_by_id(params[:id])
    logger.debug "===================purchase_advance======================"
    logger.debug @purchase_advance.inspect
    vendor=@company.accounts.find(@purchase_advance.to_account_id)
    purchase_advances = @company.gstr_advance_payments.not_in(@purchase_advance.gstr_advance_purchases_payments).by_deleted(false).by_status(0).by_vendor(vendor.id).by_currency(vendor.get_currency_id)
    purchase_advances.map { |gstr_advance_payment| @purchase_advance.gstr_advance_purchases_payments.build(:gstr_advance_payment_id=>gstr_advance_payment.id, :amount=>nil)}
    # expenses = @company.expenses.not_in(@purchase_advance.expenses).by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(vendor.id).by_currency(vendor.get_currency_id)
    # expenses.map{ |expense| @purchase_advance.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
  end

  def get
    @purchase_advance = @company.purchase_advances.find_by_id(params[:id])
    if @purchase_advance
      send_file @purchase_advance.uploaded_file.path, :type => @purchase_advance.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to purchase_advances_path
    end
  end

end
