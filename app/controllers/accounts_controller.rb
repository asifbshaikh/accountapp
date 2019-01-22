class AccountsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  respond_to :html, :json
  layout'application'#, :except=> :new

  # GET /accounts
  # GET /accounts.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => AccountDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def bank_accounts
    @accounts = Account.get_bank_accounts(@company.id).order("created_at DESC").page(params[:page])
  end

  def customer_accounts
    @accounts = Account.get_customer_accounts(@company.id).order("created_at DESC").page(params[:page])
  end

  def vendor_accounts
    @accounts = Account.get_vendor_accounts(@company.id).order("created_at DESC").page(params[:page])
  end

  def tax_accounts
    @accounts = Account.get_tax_accounts(@company.id).order("created_at DESC").page(params[:page])
  end

  def product_or_service_accounts
    @accounts = Account.get_product_or_service_accounts(@company.id).order("created_at DESC").page(params[:page])
  end

  # GET /accounts/1

  def show
    @account = @company.accounts.find(params[:id])
    #@account_head = AccountHead.find(@account.account_head_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new
    @account.start_date=@financial_year.start_date
    @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = @company.accounts.find(params[:id])
    if @account.accountable.attributes.has_key?("address") && @account.accountable.address.blank?
      @account.accountable.build_address
    end
    if @account.accountable.attributes.has_key?("contacts") && @account.accountable.contacts.blank?
      @account.accountable.contacts.build
    end

     @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
    @account_head = AccountHead.find(@account.account_head_id)
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])
    @account.company = @company
    if !@account.account_head_id.nil?
      sub_account = fetch_account_object(@account.account_head_id, params)
      @account.accountable = sub_account
    end
    @account.created_by = @current_user.id
    respond_to do |format|
      if @account.valid?
        @account.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " new #{@account.accountable_type} #{@account.name}", "created", @current_user.branch_id)
        flash[:success] = "Successfully created Account"
        format.html { redirect_to(accounts_path)}
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
       @account_heads = @company.account_heads.where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','DutiesAndTaxesAccounts')", :deleted =>false)
        if !@account.account_head_id.nil?
          @account_head = AccountHead.find(@account.account_head_id)
          @account.account_head_id = @account_head.id
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_account
    @account = Account.new(params[:account])
    @account.company = @company
    if !@account.account_head_id.nil?
      sub_account = fetch_account_object(@account.account_head_id, params)
      @account.accountable = sub_account
    end
    @account.created_by = @current_user.id
    if @account.valid?
      @account.save
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
          " new #{@account.accountable_type} #{@account.name}", "created", @current_user.branch_id)
    end
    # if params[:transaction_type] == 'tax'
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    # end
    respond_to do |format|
      format.js { render params[:return_url] }
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = @company.accounts.find(params[:id])
    respond_to do |format|
      if @account.update_attributes(params[:account])
        if !@company.plan.free_plan? && !@account.accountable.blank? && @account.accountable.attributes.has_key?("inventoriable") && !@account.reseller?
          if @account.accountable.inventoriable? &&  @account.product.blank?
            product = Product.new
            product.company_id = @account.company_id
            product.account_id = @account.id
            product.name = @account.name
            product.unit_of_measure = 'units'
            product.created_by = @current_user.id
            product.save
           elsif @account.accountable.inventoriable? && !@account.product.blank?
            @account.product.update_corresponding_product(@account.name)
          end
        end
        Workstream.register_user_action( @company.id, @current_user.id, request.remote_ip,
        "#{@account.accountable_type} #{@account.name}", "updated", @current_user.branch_id)
         if @account.accountable_type =="DutiesAndTaxesAccounts"
          format.html { redirect_to("/duties_and_taxes/index", :notice => 'Tax successfully updated.') }
         else
          format.html { redirect_to(@account, :notice => 'Account was successfully updated.') }
         end
        format.xml  { head :ok }
        format.json { head :ok }
      else
        # @account = @company.accounts.find(params[:id])
        @account_heads = AccountHead.where(:company_id => @company.id, :deleted => false)
        @account_head = AccountHead.find(@account.account_head_id)

        if @account.accountable.attributes.has_key?("address") && @account.accountable.address.blank?
          @account.accountable.build_address
        end
        if @account.accountable.attributes.has_key?("contacts") &&  @account.accountable.contacts.blank?
          @account.accountable.contacts.build
        end

         format.html { render :action => "edit" }
         format.json { respond_with_bip(@account) }
         format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }

      end
      format.js {render :action=>"mark_archive"}
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = @company.accounts.find(params[:id])
    if @account.has_product? || @account.has_ledgers? || @account.has_vouchers? || @account.has_payheads? 
      flash[:error] = "There are vouchers/payheads still relating to #{@account.name}. Please delete them before deleting the accounts."
      redirect_to :back
    else
      #Added fix where current_user was not passed to deletion method
      #Author: Ashish Wadekar
      #Date: 6 February 2017
      @account.delete(@current_user)
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
          " #{@account.accountable_type} #{@account.name} is marked for deletion", "deleted", @current_user.branch_id)
      flash[:success] = "Account was deleted"
      redirect_to accounts_path
    end
  end

  def fetch_account_object(account_head_id, params)
    account_head = AccountHead.find(account_head_id)
    root_account_head = account_head.root
    account = nil
    if root_account_head.name == "Bank Accounts"
      account = BankAccount.new(params[:bank])
    elsif root_account_head.name == "Cash Accounts"
      account = CashAccount.new(params[:cash])
    elsif root_account_head.name == "Fixed Assets"
      account = FixedAsset.new(params[:fixed])
    elsif root_account_head.name == "Loan Accounts"
      account = LoanAccount.new(params[:loan])
    elsif root_account_head.name == "Purchase Accounts"
      account = PurchaseAccount.new(params[:purchase])
    elsif root_account_head.name == "Products/Services"
      account = SalesAccount.new(params[:sales])
    elsif root_account_head.name == "Secured Loan Accounts"
      account = SecuredLoanAccount.new(params[:secured])
    elsif root_account_head.name == "Vendors (Creditors)"
      account = SundryCreditor.new(params[:creditor])
    elsif root_account_head.name == "Customers (Debtors)"
      account = SundryDebtor.new(params[:debtor])
      if !params[:start_hrs].blank? && !params[:end_hrs].blank?
        tmp = params[:start_hrs].to_s
        tmp += ':'.to_s
        tmp += params[:start_mins].to_s
        tmp1 = params[:end_hrs].to_s
        tmp1 += ':'.to_s
        tmp1 += params[:end_mins].to_s
        weekly_off = params[:weekly_off].join(',')
        account.open_time = tmp
        account.close_time = tmp1
        account.weekly_off = weekly_off.to_s
      end
    elsif root_account_head.name == "Unsecured Loan Accounts"
      account = UnsecuredLoanAccount.new(params[:unsecured])
    elsif root_account_head.name == "Direct Expenses"
      account = DirectExpenseAccount.new(params[:direct])
    elsif root_account_head.name == "Indirect Expenses"
      account = IndirectExpenseAccount.new(params[:indirect])
    elsif root_account_head.name == "Investments"
      account = InvestmentAccount.new(params[:investment])
    elsif root_account_head.name == "Suspense Accounts"
      account = SuspenseAccount.new(params[:suspense])
    elsif root_account_head.name == "Provisions"
      account = ProvisionAccount.new(params[:provision])
    elsif root_account_head.name == "Deposits"
      account = DepositAccount.new(params[:deposit])
    elsif root_account_head.name == "Capital Accounts"
      account = CapitalAccount.new(params[:capital])
    elsif root_account_head.name == "Loans and advances"
      account = LoansAdvancesAccount.new(params[:advance])
    elsif root_account_head.name == "Duties and Taxes"
      account = DutiesAndTaxesAccounts.new(params[:duties])
    elsif root_account_head.name == "Direct Income"
      account = DirectIncomeAccount.new(params[:income])
    elsif root_account_head.name == "Indirect Income"
      account = IndirectIncomeAccount.new(params[:indirect_income])
    elsif root_account_head.name == "Current Assets"
      account = CurrentAsset.new(params[:current_asset])
    elsif root_account_head.name == "Other Current Assets"
      account = OtherCurrentAsset.new(params[:other_current_asset])
    elsif root_account_head.name == "Current Liabilities"
      account = CurrentLiability.new(params[:current_liability])
    elsif root_account_head.name == "Reserves and Surplus"
      account = ReservesAndSurplusAccount.new(params[:reserves_and_surplus])
    elsif root_account_head.name == "Deferred Tax Asset Or Liability"
      account = DeferredTaxAssetOrLiability.new(params[:deferred_tax_asset_or_liability])
    end
    account
  end

  def account_partial
    @account_head = AccountHead.find(params[:account_head_id])
  end

  def sundrydebtor_popup
    @account = Account.new
    respond_to do |format|
      format.html{render :layout => false}
    end
  end

  def self.fetch_account_head(account_head_id, params)
    account_head = AccountHead.find(account_head_id)
    root_account_head = account_head.root
    account = nil
    if root_account_head.name == "Bank Accounts"
      account = BankAccount.new
      account.account_number = params[:account_number]
      account.bank_name = params[:bank_name]
    elsif root_account_head.name == "Cash Accounts"
      account = CashAccount.new
      account.location = params[:location]
    elsif root_account_head.name == "Loan Accounts"
      account = LoanAccount.new
      account.account_number = params[:account_number]
      account.bank_name = params[:bank_name]
    elsif root_account_head.name == "Products/Services"
      account = SalesAccount.new
      account.inventoriable = params[:inventoriable]
      account.description = params[:description]
  	  account.unit_cost = params[:unit_rate]
    elsif root_account_head.name == "Secured Loan Accounts"
      account = SecuredLoanAccount.new
      account.bank_name = params[:bank_name]
      account.account_number = params[:account_number]
    elsif root_account_head.name == "Customers (Debtors)"
      account = SundryDebtor.new
      account.email = params[:email]
      address = account.build_address
  	  address.address_line1 = params[:address_line1]
  	  address.address_line2 = params[:address_line2]
  	  address.city = params[:city]
  	  address.state = params[:state]
    elsif root_account_head.name == "Unsecured Loan Accounts"
      account = UnsecuredLoanAccount.new
      account.entity_name = params[:entity_name]
    elsif root_account_head.name == "Suspense Accounts"
      account = SuspenseAccount.new
    elsif root_account_head.name == "Deposits"
      account = DepositAccount.new
      account.interest_applicable = params[:interest_applicable]
      account.compounding = params[:compounding]
      account.interest_rate = params[:interest_rate]
    elsif root_account_head.name == "Capital Accounts"
      account = CapitalAccount.new
      account.name = params[:capital_name]
      account.email = params[:email]
      address = account.build_address
  	  address.address_line1 = params[:address_line1]
  	  address.address_line2 = params[:address_line2]
  	  address.city = params[:city]
  	  address.state = params[:state]
    elsif root_account_head.name == "Loans and advances"
      account = LoansAdvancesAccount.new
      account.interest_applicable = params[:interest_applicable]
      account.compounding = params[:compounding]
      account.interest_rate = params[:interest_rate]
    elsif root_account_head.name == "Direct Income"
      account = DirectIncomeAccount.new
    elsif root_account_head.name == "Indirect Income"
      account = IndirectIncomeAccount.new
    elsif root_account_head.name == "Fixed Assets"
      account = FixedAsset.new
      account.depreciation_rate = params[:depreciation_rate]
      account.depreciable = params[:depreciable]
    elsif root_account_head.name == "Investments"
      account = InvestmentAccount.new
      account.inventoriable = params[:inventoriable]
    elsif root_account_head.name == "Direct Expenses"
      account = DirectExpenseAccount.new
      account.inventoriable = params[:inventoriable]
    elsif root_account_head.name == "Indirect Expenses"
      account = IndirectExpenseAccount.new
      account.inventoriable = params[:inventoriable]
    elsif root_account_head.name == "Provisions"
      account = ProvisionAccount.new
    elsif root_account_head.name == "Vendors (Creditors)"
      account = SundryCreditor.new
      account.email = params[:email]
      address = account.build_address
      address.address_line1 = params[:address_line1]
      address.address_line2 = params[:address_line2]
      address.city = params[:city]
      address.state = params[:state]
    elsif root_account_head.name == "Duties and Taxes"
      account = DutiesAndTaxesAccounts.new
      account.tax_rate = params[:tax_rate]
      account.auto_calculate_tax = true
      account.tax = params[:tax]
    elsif root_account_head.name == "Purchase Accounts"
      account = PurchaseAccount.new
      account.inventoriable = params[:inventoriable]
      account.reseller_product = params[:reseller_product]
      account.description = params[:description]
  	  account.unit_cost = params[:unit_rate]
    end
    account
  end

  def add_account
    @data_account = nil
    if params[:transaction_type] == 'customer'
      @account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @data_account = 'customer'
    elsif params[:transaction_type] == 'item'
      @account_head = AccountHead.get_sales_account(@company.id)
      @data_account = "item"
    elsif params[:transaction_type] == 'tax'
      @account_heads = nil
      @account_head = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
    end
    respond_to do |format|
      format.js
    end
  end

  def add_row
    @index = params[:index].to_i + 1
  end

  def invoices
    @invoices = Invoice.get_customer_invoices(@company.id, params[:account_id])
  end
  def estimates
    @estimates = Estimate.get_customer_estimates(@company.id, params[:account_id])
  end

  def receipt_vouchers
    @receipt_vouchers = ReceiptVoucher.get_customer_receipt_vouchers(@company.id, params[:account_id])
  end

  def account_detail
    @account = @company.accounts.find(params[:account_id])
  end

  def purchases
    @purchases = Purchase.get_vendor_purchases(@company.id, params[:account_id])
  end

  def purchase_orders
    @purchase_orders = PurchaseOrder.get_vendor_purchase_orders(@company.id, params[:account_id])
  end

  def payment_vouchers
    @payment_vouchers = PaymentVoucher.get_vendor_payment_vouchers(@company.id, params[:account_id])
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
