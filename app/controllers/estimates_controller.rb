class EstimatesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /estimates
  # GET /estimates.xml
  def index
    @customers = @company.customers.select("id, name").to_json

    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @estimates }
      format.json { render :json => EstimateDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_estimate
    @search = @company.estimates.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @estimates = @search.order("estimate_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @estimates }
    end
  end

  # GET /estimates/1
  # GET /estimates/1.xml
  def show
    @currency = @company.currency_code
    @estimate = @company.estimates.find(params[:id])
    @estimate_line_items = @estimate.estimate_line_items
    @tax_line_items = @estimate.tax_line_items.group(:account_id)
    @shipping_line_items = @estimate.shipping_line_items
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Estimate", true)
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        Estimate.create_estimate_history(@estimate.id,@company.id,@current_user.id,"printed")
        pdf=EstimatePdf.new(@estimate, view_context, @custom_field, @estimate_line_items, @tax_line_items, @shipping_line_items)
        send_data pdf.render, :filename=>"#{@estimate.estimate_number}.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
      format.xml  { render :xml => @estimate }
      if params[:print]=="yes"
         Estimate.create_estimate_history(@estimate.id,@company.id,@current_user.id,"printed")
         end
       # prawnto :filename => "#{@estimate.estimate_number}.pdf"
    end
  end

  def convert_to_so
    @estimate = @company.estimates.find(params[:id])
    SalesOrder.create_from_estimate(@estimate, @company, request.remote_ip, @financial_year)
    Estimate.update_status(@estimate.id, 2)
    @sales_order = SalesOrder.find_by_estimate_id(@estimate.id)
    respond_to do |format|
      if @sales_order.status==4
        format.html {redirect_to(edit_sales_order_path(@sales_order), :notice=> "Estimate successfully converted to sales order")}
      else
        format.html {redirect_to(sales_order_path(@sales_order), :notice=> "Estimate successfully converted to sales order")}
      end
      format.xml { render :xml => @estimate}
    end
  end

  # GET /estimates/new
  # GET /estimates/new.xml
  def new
    @estimate = Estimate.new_estimate(params, @company)
    @states = State.where(country_id: 93)
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 1)
    @estimate.estimate_number = VoucherSetting.next_estimate_number(@company)
    @from_accounts = Product.get_sales_products(@company.id)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Estimate")
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    respond_to do |format|
      format.html { render :html => @estimate } # new.html.erb
      format.xml  { render :xml => @estimate }
    end
  end

  # GET /estimates/1/edit
  def edit
    @estimate = @company.estimates.find(params[:id])
    @states = State.where(country_id: 93)
    @estimate.estimate_line_items.each do |line_item|
      (2-line_item.estimate_taxes.count).times{line_item.estimate_taxes.build}
    end
    @estimate.old_file_size = @estimate.attachment_file_size
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 1)
    @from_accounts = Product.get_sales_products(@company.id)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Estimate")
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
  end

  # POST /estimates
  # POST /estimates.xml
  def create
    @estimate = Estimate.create_estimate(params, @company.id, @current_user, @financial_year.year.name)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Estimate")
    # @estimate.build_tax
    respond_to do |format|
      if @estimate.save
        Estimate.create_estimate_history(@estimate.id,@company.id,@current_user.id,"created")
        @estimate.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@estimate, :notice => 'Estimate was successfully created.') }
        format.xml  { render :xml => @estimate, :status => :created, :location => @estimate }
      else
        @estimate.estimate_line_items.each do |line_item|
          (2-line_item.estimate_taxes.size).times{line_item.estimate_taxes.build}
        end
        @states = State.where(country_id: 93)
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 1)
        @from_accounts = Product.get_sales_products(@company.id)
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        format.html { render :action => "new" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /estimates/1
  # PUT /estimates/1.xml
  def update
    @estimate = Estimate.update_estimate(params, @company.id, @current_user, @financial_year.year.name)
    @estimate.total_amount= @estimate.get_total_amount
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Estimate")
    respond_to do |format|
      if @estimate.valid? 
        @estimate.save
        @estimate.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@estimate, :notice => 'Estimate was successfully updated.') }
        format.xml  { head :ok }
      else
        @estimate.estimate_line_items.each do |line_item|
          (2-line_item.estimate_taxes.size).times{line_item.estimate_taxes.build}
        end
        @states = State.where(country_id: 93)
        @from_accounts = Product.get_sales_products(@company.id)
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 1)
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

   def customer_details
    account = @company.accounts.find_by_name(params[:account_name])
    if account.present?
      @customer = account.customer.blank? ? account.vendor : account.customer
      @gstin = @customer.gstn_id
    end  
    respond_to do |format|
      format.js
    end
  end

  #soft delete Estimate
  def destroy
    @estimate = @company.estimates.find(params[:id])
    @estimate.fin_year = @financial_year.year.name
    respond_to do |format|
      if @estimate.destroy
        @estimate.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to(estimates_url, :notice => "estimate has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.estimates.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @estimates = @search.order("estimate_date DESC").page(params[:page]).per(20)
        flash[:error] = "The estiamte was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def restore_estimate
    @estimate = @company.estimates.find(params[:id])
    @estimate.fin_year = @financial_year.year.name
    respond_to do |format|
      if @estimate.restore(@current_user.id)
        @estimate.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(estimates_url, :notice => "estimate has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.estimates.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @estimates = @search.order("estimate_date DESC").page(params[:page]).per(20)
        flash[:error] = "The estimate was not restored due to an error."
        format.html { render :action => "deleted_estimate" }
        format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete estimate
  def permanent_delete_estimate
    @estimate = @company.estimates.find(params[:id])
    respond_to do |format|
		if @estimate.destroy
      @estimate.register_user_action(request.remote_ip, 'deleted')
		  format.html { redirect_to(estimates_deleted_estimate_url, :notice => "Estimate has been permanently deleted") }
		  format.xml  { head :ok }
		else
			@search = @company.estimates.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
      @estimates = @search.order("estimate_date DESC").page(params[:page]).per(20)
			flash[:error] = "The estiamte was not deleted due to an error."
			format.html { render :action => "deleted_estimate" }
			format.xml  { render :xml => @estimate.errors, :status => :unprocessable_entity }
		end
    end
  end

  def add_row
    @estimate_line_item = EstimateLineItem.new
    2.times {@estimate_line_item.estimate_taxes.build}
    @from_accounts = Product.get_sales_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = EstimateLineItem.new
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end

  def add_shipping_row
    @shipping_line_item = EstimateLineItem.new
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    respond_to do |format|
      format.js
    end
  end

  def remove_tax_item
  end

  def remove_line_item
  end

  def remove_shipping_item
    #we just want this method to pass to the erb
  end

 def add_account
    @data_account = nil
    if params[:transaction_type] == 'customer'
      @account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @data_account = 'customer'
    elsif params[:transaction_type] == 'item'
      @account_heads = AccountHead.get_sales_account(@company.id)
      @data_account = "item"
    elsif params[:transaction_type] == 'tax'
      # @account_heads = nil
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
    end

  end

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
  end

  #action to email estimate in an attachment
  def create_estimate_email
    current_company = @company
    @estimate = @company.estimates.find(params[:id])
  end

  def email_estimate
    @estimate = @company.estimates.find(params[:id])
    @estimate_line_items = @estimate.estimate_line_items
    @tax_line_items = @estimate.tax_line_items.group(:account_id)
    @shipping_line_items = @estimate.shipping_line_items
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Estimate", true)
    to_email = params[:email]
    to_email = to_email.gsub(/\s+/, " ").strip
    subject = params[:subject]
    text = params[:text]
    pdf=EstimatePdf.new(@estimate, view_context, @custom_field, @estimate_line_items, @tax_line_items, @shipping_line_items)
    attachment=pdf.render
    @email_valid = validate_email?(to_email)
    if @email_valid
      Email.send_estimate(attachment, @estimate, @company, @current_user, subject, text, to_email).deliver
      Estimate.create_estimate_history(@estimate.id,@company.id,@current_user.id,"sent to #{to_email}")
      flash[:success] = 'Email has been sent successfully.'
    else
      flash[:error]='Email is either blank or invalid. If you have entered multiple emails please separate them with commas and not more than 6 emails are allowed'
    end
  end

 private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
