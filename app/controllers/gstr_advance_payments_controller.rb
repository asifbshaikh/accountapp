class GstrAdvancePaymentsController < ApplicationController
   # rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # GET /gstr_advance_payments
  # GET /gstr_advance_payments.json
  def index
    #@customers = @company.customers.select("id, name").to_json
    respond_to do |format|

      format.json { render :json => GstrAdvancePaymentDatatable.new(view_context, @company, @current_user, @financial_year)}
      
      format.html # index.html.erb
      # format.json  { render :json => ReceiptVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
      # format.json  { render :json => IncomeVouchersDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /gstr_advance_payments/1
  # GET /gstr_advance_payments/1.json
  def show
    @currency = @company.currency_code
    @gstr_advance_payment = @company.gstr_advance_payments.find(params[:id])
    @gstr_advance_payment_line_items = @gstr_advance_payment.gstr_advance_payment_line_items
    @tax_line_items = @gstr_advance_payment.tax_line_items.group(:account_id)
    @shipping_line_items = @gstr_advance_payment.shipping_line_items
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        GstrAdvancePayment.create_gstr_advance_payment_history(@gstr_advance_payment.id,@company.id,@current_user.id,"printed")
        pdf = GstrAdvancePaymentPdf.new(@gstr_advance_payment, view_context, @gstr_advance_payment_line_items, @tax_line_items, @shipping_line_items)
        send_data pdf.render, :filename=>"#{@gstr_advance_payment.voucher_number}.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
      format.xml  { render :xml => @gstr_advance_payment }
      if params[:print]=="yes"
         GstrAdvancePayment.create_gstr_advance_payment_history(@gstr_advance_payment.id,@company.id,@current_user.id,"printed")
         end
       # prawnto :filenamegstr_advance_payment.gstr_advance_payment_number}.pdf"
    end
  end

  # def convert_to_so
  #   @gstr_advance_payment = @company.gstr_advance_payments.find(params[:id])
  #   SalesOrder.create_from_gstr_advance_payment(@gstr_advance_payment, @company, request.remote_ip, @financial_year)
  #   GstrAdvancePayment.update_status(@gstr_advance_payment.id, 2)
  #   @sales_order = SalesOrder.find_by_gstr_advance_payment_id(@gstr_advance_payment.id)
  #   respond_to do |format|
  #     if @sales_order.status==4
  #       format.html {redirect_to(edit_sales_order_path(@sales_order), :notice=> "GstrAdvancePayment successfully converted to sales order")}
  #     else
  #       format.html {redirect_to(sales_order_path(@sales_order), :notice=> "GstrAdvancePayment successfully converted to sales order")}
  #     end
  #     format.xml { render :xml => @gstr_advance_payment}
  #   end
  # end

  # GET /gstr_advance_payments/new
  # GET /gstr_advance_payments/new.json
  def new
    @gstr_advance_payment = GstrAdvancePayment.new_gstr_advance_payment(params, @company, @current_user)
    @from_accounts = TransactionType.fetch_to_accounts(@company.id,'sales')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @bank_accounts = TransactionType.fetch_to_accounts(@company.id,'receipts')
    @gstr_advance_payment_line_item = @gstr_advance_payment.gstr_advance_payment_line_items
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @vendor_id =Vendor.find_by_company_id(@company.id)
    @products = Product.get_sales_products(@company.id)
    @voucher_setting = VoucherSetting.find_by_voucher_type(26, @company.id)
    @states = State.where(country_id: 93)

    @gstr_advance_payment.gstr_advance_payment_line_items.each do |line_item|
      2.times{line_item.gstr_advance_payment_taxes.build}
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gstr_advance_payment }
    end
  end

  # GET /gstr_advance_payments/1/edit
  def edit
    @gstr_advance_payment = @company.gstr_advance_payments.find(params[:id])
    @gstr_advance_payment.gstr_advance_payment_line_items.each do |line_item|
      (2-line_item.gstr_advance_payment_taxes.count).times{line_item.gstr_advance_payment_taxes.build}
    end
#    @gstr_advance_payment.old_file_size = @gstr_advance_payment.attachment_file_size
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 26)
    @products = Product.get_sales_products(@company.id)
    @bank_accounts = TransactionType.fetch_to_accounts(@company.id,'receipts')
    @from_accounts = TransactionType.fetch_to_accounts(@company.id,'sales')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @states = State.where(country_id: 93)
  end

  # POST /gstr_advance_payments
  # POST /gstr_advance_payments.json
  def create
    @gstr_advance_payment = GstrAdvancePayment.create_gstr_advance_payment(params, @company, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @gstr_advance_payment.save_with_ledgers && @gstr_advance_payment.valid?
        VoucherSetting.next_gstr_advance_payment_voucher_write(@company)
        GstrAdvancePayment.create_gstr_advance_payment_history(@gstr_advance_payment.id,@company.id,@current_user.id,"created")
        #@gstr_advance_payment.register_user_action(request.remote_ip, 'created')
         GstrAdvancePaymentFilerWorker.perform(@company.id,@gstr_advance_payment.id)
        format.html { redirect_to(@gstr_advance_payment, :notice => 'Gstr Advance Payment was successfully created.') }
        format.xml  { render :xml => @gstr_advance_payment, :status => :created, :location => @gstr_advance_payment }
      else
        @gstr_advance_payment.gstr_advance_payment_line_items.each do |line_item|+
          (2-line_item.gstr_advance_payment_taxes.size).times{line_item.gstr_advance_payment_taxes.build}
        end
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 26)
        @gstr_advance_payment.voucher_number = @voucher_setting.gstr_advance_payment_voucher_number(@company)
        @from_accounts = TransactionType.fetch_to_accounts(@company.id,'sales')
        @products = Product.get_sales_products(@company.id)
        @bank_accounts = TransactionType.fetch_to_accounts(@company.id,'receipts')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        @states = State.where(country_id: 93)
        format.html { render :action => "new" }
        format.xml  { render :xml => @gstr_advance_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /gstr_advance_payments/1
  # PUT /gstr_advance_payments/1.json
  def update

    @gstr_advance_payment = GstrAdvancePayment.update_gstr_advance_payment(params, @company.id, @current_user, @financial_year.year.name)
    @gstr_advance_payment.amount = @gstr_advance_payment.get_total_amount
    id = @gstr_advance_payment.id
    respond_to do |format|

      if @gstr_advance_payment.valid? 
        @gstr_advance_payment.save
        @gstr_advance_payment.register_user_action(request.remote_ip, 'updated')
        @gstr_advance_payment.update_and_manage_status(request.remote_ip,id)
        GstrAdvancePaymentFilerWorker.update_entries(@company.id,@gstr_advance_payment.id)
        format.html { redirect_to(@gstr_advance_payment, :notice => 'gstr_advance_payment was successfully updated.') }
        format.xml  { head :ok }
        
        
      else
        @gstr_advance_payment.gstr_advance_payment_line_items.each do |line_item|
          (2-line_item.gstr_advance_payment_taxes.size).times{line_item.gstr_advance_payment_taxes.build}
        end
        @products = Product.get_sales_products(@company.id)
        @from_accounts = TransactionType.fetch_to_accounts(@company.id,'sales')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
        @bank_accounts = TransactionType.fetch_to_accounts(@company.id,'receipts')
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 26)
       # @gstr_advance_payment.voucher_number = @voucher_setting.gstr_advance_payment_voucher_number(@company)
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @states = State.where(country_id: 93)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gstr_advance_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /gstr_advance_payments/1
  # DELETE /gstr_advance_payments/1.json
  def destroy
    @gstr_advance_payments = GstrAdvancePayment.find_by_id_and_company_id(params[:id], @company.id)
    @gstr_advance_payments.delete_gstr_two_entry
    @gstr_advance_payments.destroy
        respond_to do |format|
      @gstr_advance_payments.register_delete_action(request.remote_ip, @current_user, 'deleted')
      format.html { redirect_to(gstr_advance_payments_url, :notice => "Gstr Advance Payments has been successfully deleted.") }
      format.xml  { head :ok }
    end
  end

  def create_allocation
    @adv_payment = GstrAdvancePayment.create_allocation(params, @company)
    logger.debug "adv_payment values #{@adv_payment.inspect}"
    respond_to do |format|
      if @adv_payment.save
        # @gstr_advance_payment.manage_purchase_and_gstr_advance_payment_status
        # @gstr_advance_payment.manage_gstr_advance_payment_status
        format.html { redirect_to gstr_advance_payment_path(@adv_payment), :notice => 'Advance Payment was successfully created.'}
      else
        format.html { render :action=>"allocate"}
      end
    end
  end

 

  def allocate

    @adv_payment = @company.gstr_advance_payments.find(params[:id])

    # @adv_payment = @company.gstr_advance_payments.find(params[:id])
    # logger.debug "===================gstr_advance_payment======================"
    # logger.debug @adv_payment.inspect
    # logger.debug @adv_payment.purchases.inspect
    # logger.debug @adv_payment.to_account.purchases.inspect

    # @purchases = @adv_payment.to_account.purchases.not_in(@adv_payment.purchases).by_status(0)
    # logger.debug "===============#{@purchases.inspect}=============="
    # logger.debug "============================After fetching all unpaid purchases============="
    # @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    # @purchases.map { |purchase| @adv_payment.gstr_advance_purchases_payments.build(:purchase_id=>purchase.id, :amount=>nil)}
    # expenses = @company.expenses.not_in(@adv_payment.expenses).by_branch_id(@current_user.branch_id).by_deleted(false).by_credit_expenses().by_status(0).by_account(vendor.id).by_currency(vendor.get_currency_id)
    # expenses.map{ |expense| @adv_payment.expenses_payments.build(:expense_id=>expense.id, :tds_amount=>nil, :amount=>nil) }
  end

  def add_row
    @gstr_advance_payment_line_item = GstrAdvancePaymentLineItem.new
    2.times {@gstr_advance_payment_line_item.gstr_advance_payment_taxes.build}
    @products = Product.get_sales_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = GstrAdvancePaymentLineItem.new
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end

  def add_shipping_row
    @shipping_line_item = GstrAdvancePaymentLineItem.new
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    respond_to do |format|
      format.js
    end
  end

  def item_name
    product_id.blank? ? Account.find(account_id).name : Product.find(product_id).name
  end


  def fetch_line_items
    purchase = @company.purchases.find(params[:id])
    @tax_accounts=TransactionType.fetch_to_accounts(@company.id, 'tax')
    @line_item_details =purchase.purchase_line_items
    logger.debug "ffffffffffffff"
    logger.debug @line_item_details.inspect
  end
  
  def save_as_draft(format)
    @gstr_advance_payment.save(:validate=>false)
    format.html {redirect_to gstr_advance_payment_path(:anchor=>"draft-gstr_advance_payment-tab"), :notice=>"Gstr Advance Payment has been saved in draft"}
  end

  def save_as_final(format)
    # @gstr_advance_payment = GstrAdvancePayment.update_purchase(params, @company, @current_user, @financial_year.year.name)
    if  @gstr_advance_payment.save_and_manage_inventory #@gstr_advance_payment.valid?
      @gstr_advance_payment.update_and_post_ledgers
      @gstr_advance_payment.update_gstr_advance_payment_status
      @gstr_advance_payment.register_user_action(request.remote_ip, "updated")
      format.html { redirect_to(@gstr_advance_payment, :notice => 'gstr_advance_payment was successfully updated.') }
      format.xml  { head :ok }
    else
      @gstr_advance_payment.gstr_advance_payment_line_items.each do |line_item|
        (2 - line_item.gstr_advance_payment_taxes.size).times{line_item.gstr_advance_payment_taxes.build}
      end
      @projects = @company.projects.where(:status => false)
      @from_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
      @to_accounts = Product.get_purchase_products(@company.id)
      @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
      @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
      @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
      @projects = @company.projects.where(:status => false)
      @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @warehouses=@company.warehouses
      format.html { render :action => "edit" }
      format.xml  { render :xml => @gstr_advance_payment.errors, :status => :unprocessable_entity }
    end
  end

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
  end

  def customer_address
    account = @company.accounts.find_by_name("#{params[:customer_name]}")
    unless account.blank?
      @customer=account.customer.blank? ? account.vendor : account.customer
    end
  end

  

  # private
  # def record_not_found
  #   flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
  #   redirect_to :action=> :index
  # end


end
