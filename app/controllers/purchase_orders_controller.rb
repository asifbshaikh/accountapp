class PurchaseOrdersController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /purchase_orders
  # GET /purchase_orders.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => PurchaseOrderDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  def deleted_purchase_order
    @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchase_orders }
    end
  end

  def open
    @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
    @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
    respond_to do |format|
      format.html # closed.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices
  # GET /invoices.xml
  def closed
    @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
    @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
    respond_to do |format|
      format.html # closed.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices
  # GET /invoices.xml
  def draft
    @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
    @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
    respond_to do |format|
      format.html # closed.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.xml
  def show
    @purchase_order = @company.purchase_orders.find(params[:id])
    @discount = @purchase_order.discount
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase_order }
      format.pdf do
        pdf=PurchaseOrderPdf.new(@purchase_order)
        send_data pdf.render, :filename=>"#{@purchase_order.purchase_order_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      # prawnto :filename => "#{@purchase_order.purchase_order_number}.pdf"
    end
  end

  # GET /purchase_orders/new
  # GET /purchase_orders/new.xml
  def new
    @purchase_order = PurchaseOrder.new_order(params, @company)
    @purchase_order.purchase_order_line_items.each do |line_item|
      2.times{ line_item.purchase_order_taxes.build }
    end
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 6)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @to_accounts = Product.get_purchase_products(@company.id)
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
    @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @projects = @company.projects.active
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @purchase_order }
    end
  end

  # GET /purchase_orders/1/edit
  def edit
    @purchase_order = @company.purchase_orders.find(params[:id])
    @purchase_order.purchase_order_line_items.each do |line_item|
      (2-line_item.purchase_order_taxes.size).times{ line_item.purchase_order_taxes.build }
    end
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 6)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
    @to_accounts = Product.get_purchase_products(@company.id)
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @purchase_order.old_file_size = @purchase_order.uploaded_file_file_size
    @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
    @projects = @company.projects.active
    @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  end

  # POST /purchase_orders
  # POST /purchase_orders.xml
  def create
    @purchase_order = PurchaseOrder.create_order(params, @company.id, @current_user, @financial_year.year.name)
    # @purchase_order.build_tax
    respond_to do |format|
      if @purchase_order.save
        VoucherSetting.next_purchase_order_write(@company)
        @purchase_order.update_attributes(:total_amount=>@purchase_order.amount)
        @purchase_order.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@purchase_order, :notice => 'Purchase order was successfully created.') }
        format.xml  { render :xml => @purchase_order, :status => :created, :location => @purchase_order }
      else
        @purchase_order.purchase_order_number = VoucherSetting.next_purchase_order_number(@company)
        @purchase_order.purchase_order_line_items.each do |line_item|
          (2-line_item.purchase_order_taxes.size).times{ line_item.purchase_order_taxes.build }
        end
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 6)
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
        @to_accounts = Product.get_purchase_products(@company.id)
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
        @projects = @company.projects.active
        @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
        @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @purchase_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_orders/1
  # PUT /purchase_orders/1.xml
  def update
    @purchase_order = PurchaseOrder.update_order(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @purchase_order.save
        @purchase_order.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@purchase_order, :notice => 'Purchase order was successfully updated.') }
        format.xml  { head :ok }
      else
        @purchase_order.purchase_order_line_items.each do |line_item|
          (2-line_item.purchase_order_taxes.size).times{ line_item.purchase_order_taxes.build }
        end
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 6)
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
        @to_accounts = Product.get_purchase_products(@company.id)
        @projects = @company.projects.active
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
        @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
        @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @purchase_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  #soft delete purchase_order
  def destroy
    @purchase_order = @company.purchase_orders.find(params[:id])
    @purchase_order.fin_year = @financial_year.year.name
    respond_to do |format|
      if @purchase_order.destroy
        @purchase_order.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to(purchase_orders_url, :notice => "Purchase order has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
        flash[:error] = "The purchase order was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @purchase_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  #restore purchase
  def restore_purchase_order
    @purchase_order = @company.purchase_orders.find(params[:id])
    @purchase_order.fin_year = @financial_year.year.name
    respond_to do |format|
      if @purchase_order.restore(@current_user.id)
        @purchase_order.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(purchase_orders_url, :notice => "Purchase order has been successfully restored") }
        format.xml  { head :ok }
      else
        @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
        flash[:error] = "The purchase order was not restored due to an error."
        format.html { render :action => "deleted_purchase_order" }
        format.xml  { render :xml => @purchase_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete purchase
  def permanent_delete_purchase_order
    @purchase_order = @company.purchase_orders.find(params[:id])
    respond_to do |format|
    	if @purchase_order.destroy
        @purchase_order.register_user_action(request.remote_ip, 'deleted')
    	  format.html { redirect_to(purchase_orders_deleted_purchase_order_url, :notice => "Purchase order has been permanently deleted") }
    	  format.xml  { head :ok }
    	else
        @search= @company.purchase_orders.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @purchase_orders = @search.order(:record_date).page(params[:page]).per(20)
        flash[:error] = "The purchase order was not restored due to an error."
        format.html { render :action => "deleted_purchase_order" }
        format.xml  { render :xml => @purchase_order.errors, :status => :unprocessable_entity }
      end
    end
  end


  def add_row
    @purchase_order_line_item = PurchaseOrderLineItem.new
    2.times{ @purchase_order_line_item.purchase_order_taxes.build }
    @to_accounts = Product.get_purchase_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = PurchaseOrderLineItem.new
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end

  def add_other_charge_row
    @other_charge_line_item = PurchaseOrderLineItem.new
    @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
    respond_to do |format|
      format.js
    end
  end

  def remove_tax_item
   #need for ajax call only
  end

  def remove_line_item
   #need for ajax call only
  end

  def remove_other_charge_item
    #we just want this method to pass to the erb
  end

  #this action will let the users download the files (after a simple authorization check)
  def get
    @purchase_order = @company.purchase_orders.find_by_id(params[:id])
    if @purchase_order
      send_file @purchase_order.uploaded_file.path, :type => @purchase_order.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to purchase_orders_path
    end
  end

  def add_account
    @data_account = nil
    if params[:transaction_type] == 'vendor'
      @account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @data_account = 'vendor'
    elsif params[:transaction_type] == 'item'
      @account_heads = AccountHead.get_purchase_head(@company.id)
      @data_account = "item"
    elsif params[:transaction_type] == 'tax'
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
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

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
  end

  #action to email PO in an attachment
  def create_purchase_order_email
    @purchase_order = @company.purchase_orders.find(params[:id])
  end

  def email_purchase_order
    @purchase_order=@company.purchase_orders.find(params[:id])
    @billing_address = @purchase_order.vendor.addresses.build({:address_type=>1})
    pdf=PurchaseOrderPdf.new(@purchase_order)
    mail_to = params[:email]
    mail_to = mail_to.gsub(/\s+/, " ").strip
    subject = params[:subject]
    cc = params[:cc]
    cc = cc.gsub(/\s+/, " ").strip
    text = params[:text]
    @email_valid =  validate_email?(mail_to+','+cc)
    if @email_valid
      Email.send_purchase_order(pdf.render, @purchase_order, @company, @current_user, subject, text, mail_to, cc).deliver
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

def validate_email?(email_string)
    #return false if email is blank
    return false if email_string.blank?
    #remove all white space
    to_email = email_string#.gsub(/\s+/, "")
    #check for presence of multiple emails
    if(to_email.count(',')>0 && to_email.count(',')<6)
      result = true
      emails_array = to_email.split(",")
      emails_array.each do |email|
        if !valid_email_address?(email.squish)
          result = false
          break
        end
      end
      return result
    else
      return valid_email_address?(to_email)
    end
  end

  #[OPTIMIZE] Move this method to module and use it everywhere
  def valid_email_address?( value )
    begin
     parsed = Mail::Address.new(value)
     return parsed.address == value && parsed.local != parsed.address
    rescue Mail::Field::ParseError
      return false
    end
  end

end
