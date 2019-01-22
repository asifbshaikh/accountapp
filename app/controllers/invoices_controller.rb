class InvoicesController < ApplicationController
  require 'net/http'

  # rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /invoices
  # GET /invoices.xml
  # GET /index.json
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => InvoiceDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def batch_details

  end

  def take_batch_quantity
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
    @stocks = @product.stocks unless @product.blank?
  end


  # GET /invoices
  # GET /invoices.xml
  def draft
    @search = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).by_status(1).search(params[:search])
    @invoices = @search.order("invoice_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # closed.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  def recursive_invoices
    @search = @company.invoices.where(:recursive_invoice => 1).by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
    @invoices = @search.order("invoice_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # closed.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  def deleted_invoice
    @search = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @invoices = @search.order("invoice_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.xml
  def show
    @currency = @company.currency_code
    @invoice = @company.invoices.find(params[:id])
    #@invoice_attachment = InvoiceAttachment.where('invoice_id=?',@invoice.id)
    @invoice_attachment = @invoice.invoice_attachments
    @billing_address=@invoice.billing_address.blank? ? Address.new : @invoice.billing_address
    @shipping_address=@invoice.shipping_address.blank? ? Address.new : @invoice.shipping_address

    # @link_history=InstamojoPaymentLinks.joins(:invoice).where("invoices.id= instamojo_payment_links.invoice_id").order("created_at desc").limit(1)
    @link_history=@invoice.instamojo_payment_links.last
    @cflink_history= @invoice.cashfree_payment_links.last
    #@invoice_history = InvoiceHistory.where(:invoice_id => params[:id]).order("record_date DESC")
    @invoice_history = @invoice.invoice_histories
    if  !@link_history.blank? &&  !@cflink_history.blank? &&  @company.invoice_setting.enable_cashfree && @company.invoice_setting.enable_gateway
      @longurl="Instamojo link: #{@link_history.longurl} or CashFree link: #{@cflink_history.shorturl}"
    elsif !@link_history.blank? && @company.invoice_setting.enable_gateway
      @longurl= "Instamojo : #{@link_history.longurl}"
    elsif !@cflink_history.blank? && @company.invoice_setting.enable_cashfree
      @longurl="CashFree Link:  #{@cflink_history.shorturl}"
    end

    @key_active=InstamojoPayments.where(:company_id => @company.id).order("created_at desc").limit(1)
    @key_active.each do |key|
      @apikey = key.api_key
      @authkey= key.auth_key
    end

    if @apikey.blank? && @authkey.blank?
      @info=true
    else
      @info=false
    end
    @cashfree_key_active=CashFreeSetting.where(:company_id => @company.id).order("created_at desc").limit(1)
    @cashfree_key_active.each do |key|
      @appid = key.app_id
      @secretkey= key.secret_key
    end
    if @appid.blank? && @secretkey.blank?
      @cfinfo=true
    else
      @cfinfo=false
    end

    @templates = CompanyTemplate.where(:voucher_type => "Invoice", :company_id=>@company.id).first

    @margin = TemplateMargin.find_by_template_id_and_company_id(@templates.template_id,@company.id)
    @invoice_line_items = @invoice.invoice_line_items
    @tax_line_items = @invoice.tax_line_items.group(:account_id)
    @time_line_items = @invoice.time_line_items
    @shipping_line_items = @invoice.shipping_line_items
    @receipt_vouchers = @invoice.invoices_receipts
    @projects = @company.projects.where(:status => false)
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Invoice", true)
    @receipt_voucher = ReceiptVoucher.new_receipt(params, @company, @current_user, @invoice.account)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_accounts = Product.get_sales_products(@company.id)
    @sales_orders = @invoice.sales_orders
    @expense_accounts=@company.accounts.by_accountable_type("IndirectExpenseAccount")
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        template=Invoice.get_template(@company, "Invoice", params[:dlc])
        title = {"2"=>"Duplicate for transporter", "3"=>"Triplicate for supplier"}
        title.default = "Original for Recipient"
        pdf_name = title[params[:value]]
        pdf=InvoicePdf.new(@invoice, view_context, template,@margin, @custom_field, @invoice_line_items, @time_line_items, @shipping_line_items, @tax_line_items, @receipt_vouchers,pdf_name)
        send_data pdf.render, :filename=>"#{@invoice.invoice_number}.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
      format.xml  { render :xml => @invoice }
      if params[:dlc] == "yes"
        @invoice.create_invoice_history(@invoice.id,@company.id,@current_user.id,"delivery challan printed")
      elsif params[:dlc] == "no"
        @invoice.create_invoice_history(@invoice.id,@company.id,@current_user.id,"printed")
      end
    end
  end

  # GET /invoices/new
  # GET /invoices/new.xml
  def new
    @invoice = Invoice.new_invoice @company, @current_user, @financial_year, request.remote_ip, params
    respond_to do |format|
      format.html {redirect_to edit_invoice_path(@invoice)}
      format.xml { render :xml => @invoice }
    end
  end

  # action to copy invoice into new
  def copy_invoice
    @source_invoice = @company.invoices.find_by_id(params[:id])
    @invoice=Invoice.copy_into_new(@source_invoice, @current_user, @company, @financial_year, request.remote_ip)
    respond_to do |format|
      format.html {redirect_to edit_invoice_path(@invoice)}
      format.xml { render :xml => @invoice }
    end
  end

  # method to convert estimate into invoice
  def converted_from_estimate
    @estimate = @company.estimates.find_by_id(params[:estimate_id])
    @invoice = Invoice.copy_into_new(@estimate, @current_user, @company, @financial_year, request.remote_ip)
    Estimate.update_status(@estimate.id, 1)
    respond_to do |format|
      format.html {redirect_to edit_invoice_path(@invoice)}
      format.xml { render :xml => @invoice }
    end
  end

  # method to create invoice from sales order
  def created_from_sales_order
    if params[:id].present?
      @invoice = Invoice.find_by_id_and_company_id(params[:id], @company.id)
      @invoice.financial_year_id=@financial_year.id if @invoice.financial_year_id.blank?
      @sales_order = @invoice.sales_orders.first
    else
      @sales_order = @company.sales_orders.find_by_id(params[:sales_order_id])
      @invoice = Invoice.copy_into_new(@sales_order, @current_user, @company, @financial_year, request.remote_ip)
      @invoice.invoice_sales_orders << InvoiceSalesOrder.new(:invoice_id=> @invoice.id, :sales_order_id=>@sales_order.id)
    end
    @states = State.where(country_id: 93)
    @billing_address=@invoice.billing_address.blank? ? Address.new : @invoice.billing_address
    @shipping_address=@invoice.shipping_address.blank? ? Address.new : @invoice.shipping_address
    @projects = @company.projects.where(:status => false)
    @products = Product.get_sales_products(@company.id)
    @from_accounts = Product.get_sales_products(@company.id)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice", :status=>true)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
  end

  # GET /invoices/1/edit
  def edit
    @invoice = Invoice.find_by_id_and_company_id(params[:id], @company.id)
    @invoice.invoice_line_items.each do |line_item|
      (2-line_item.invoice_taxes.size).times{line_item.invoice_taxes.build}
    end
    if @invoice.time_invoice?
      @invoice.time_line_items.each do |line_item|
        (1-line_item.invoice_taxes.size).times{line_item.invoice_taxes.build}
      end
    end
    @invoice.financial_year_id=@financial_year.id if @invoice.financial_year_id.blank?
    #[FIXME] What is the need of this cash customers ? 
    @cash_customers = @company.invoices
    @projects = @company.projects.where(:status => false)
    if @invoice.cash_invoice
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    else
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    end
    @billing_address=@invoice.billing_address.blank? ? Address.new : @invoice.billing_address
    @shipping_address=@invoice.shipping_address.blank? ? Address.new : @invoice.shipping_address
    @products = Product.get_sales_products(@company.id) if !@invoice.time_invoice?
    @port_codes = ExportPortCode.all
    @time_accounts = Task.where(:company_id => @company.id, :billable => true) if @invoice.time_invoice?
    @from_accounts = Product.get_sales_products(@company.id)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice", :status=>true)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @states = State.where(country_id: 93)
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    @sales_order = @company.sales_orders.find_by_id(params[:sales_order_id])
    @estimate = @company.estimates.find_by_id(params[:estimate_id])
    @invoice = Invoice.create_invoice(params, @company.id, @current_user, @financial_year.year.name)
    @cash_customers = @company.invoices
    @projects = @company.projects.where(:status => false)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice", :status=>true)
    @products = Product.get_sales_products(@company.id)
    respond_to do |format|
      if @invoice.valid?
        @invoice.save_with_ledgers
        if @invoice.so_invoice?
          @invoice.invoice_sales_orders << InvoiceSalesOrder.new(:invoice_id=> @invoice.id, :sales_order_id=>@sales_order.id)
          @sales_order.update_billing_status
        else
          @invoice.invoice_line_items.each do |line_item|
            if line_item.inventoriable? && @company.plan.is_inventoriable?
              product = line_item.product
              if product.batch_enable?
                line_item.sales_warehouse_details.each do |warehouse|
                  product_batch = ProductBatch.find_by_id warehouse.product_batch_id
                  product_batch.update_attributes(:quantity => (product_batch.quantity - warehouse.quantity)) unless product_batch.blank?
                      # Stock.reduce(@company.id, product.id, warehouse.warehouse_id, warehouse.quantity)
                    end
                  else
                    line_item.sales_warehouse_details.each do |warehouse|
                      Stock.reduce(@company.id, product.id, warehouse.warehouse_id, warehouse.quantity)
                    end
                  end
                end
              end
            end

            @invoice.register_user_action(request.remote_ip, 'created')
            @invoice.create_invoice_history(@invoice.id,@company.id,@current_user.id,"created")
            if !@estimate.blank?
             Estimate.update_status(@estimate.id, 1)
           end
          # end
          format.html { redirect_to(@invoice.id.blank? ? @invoice : @invoice , :notice => 'Invoice has been successfully created.') }
          format.xml  { render :xml => @invoice, :status => :created, :location => @invoice }
        else
          @invoice.invoice_status_id = nil
          @projects = @company.projects.where(:status => false)
          @cash_customers = @company.invoices
          if !params[:cash_invoice].blank? && params[:cash_invoice]=='true'
           @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
         else
           @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
         end
         @time_accounts = Task.where(:company_id => @company.id, :billable => true)
         @from_accounts = Product.get_sales_products(@company.id)
         @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
         @shipping_accounts = Account.get_other_expense_accounts(@company)
         @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
         @sales_account_heads = AccountHead.get_sales_account(@company.id)
         @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)

         if !@estimate.blank?
           format.html { render :action => "converted_from_estimate" }
         elsif !@sales_order.blank?
          format.html { render :action => "created_from_sales_order" }
        else
          format.html { render :action => "new" }
        end
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
      # end
    end
  end

  # [FIXME] Can be removed if not called from anywhere
  def save_as_draft(format)
    @invoice.save_as_draft
    format.html { redirect_to(invoices_path, :notice => 'Invoice has been saved in draft.') }
  end

  def show_validations(format)
    @invoice.invoice_line_items.each do |line_item|
      (2-line_item.invoice_taxes.size).times{line_item.invoice_taxes.build}
    end
    if @invoice.time_invoice?
      @invoice.time_line_items.each do |line_item|
        (1-line_item.invoice_taxes.size).times{line_item.invoice_taxes.build}
      end
    end
    @sales_order = @invoice.sales_orders.first if @invoice.so_invoice?
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice", :status=>true)
    @products = Product.get_sales_products(@company.id)
    @cash_customers = @company.invoices
    @projects = @company.projects.where(:status => false)
    if @invoice.cash_invoice?
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    else
      @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    end
    @warehouses=@company.warehouses
    @time_accounts = Task.where(:company_id => @company.id, :billable => true)
    @from_accounts = Product.get_sales_products(@company.id)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @billing_address=@invoice.billing_address.blank? ? Address.new : @invoice.billing_address
    @shipping_address=@invoice.shipping_address.blank? ? Address.new : @invoice.shipping_address
    @states = State.where(country_id: 93)
    if @invoice.so_invoice?
      format.html { render :action => "created_from_sales_order" }
    else
      format.html { render :action => "edit" }
    end
  end


  def update_address
    @invoice = Invoice.find(params[:id])
    logger.debug @invoice.inspect
    respond_to do |format|

    if @invoice.update_attributes(params[:invoice])
       format.js {render "address"}
       format.html { redirect_to @invoice, :notice => 'Address was successfully updated.' }
        format.json { head :ok }
    else
      if @invoice.billing_address.blank? || @invoice.shipping_address.blank?
          @billing_address = @invoice.billing_address.blank? ? @invoice.addresses.build({:address_type=>1}) : @invoice.billing_address
          @shipping_address = @invoice.shipping_address.blank? ? @invoice.addresses.build({:address_type=>0}) : @invoice.shipping_address
        else
          @billing_address = @invoice.billing_address
          @shipping_address = @invoice.shipping_address
        end
        format.json { head :ok }
        format.js {render "address"}
    end
  end
  end

  def save_as_final(format)
    @invoice.update_invoice_with_details(params, view_context, @current_user, request.remote_ip, @financial_year)#@invoice.valid?
    if @invoice.gst_invoice?
      InvoiceFilerWorker.perform_async(@company.id, @invoice.id) 
    end
    if @invoice.errors.any?
      show_validations(format)
    else
      format.html { redirect_to(@invoice, :notice => 'Invoice has been saved.') }
    end
  end

  def validate_first_and_go_to_next_step(format)
    if @invoice.valid?
      @invoice.invoice_status_id=0 if @invoice.original_invoice.draft?
      @invoice.invoice_line_items.each do |line_item|
        line_item.sales_warehouse_details.build(:warehouse_id=>@company.default_warehouse.id,
          :product_id=>line_item.product_id, :quantity=>line_item.quantity) if line_item.sales_warehouse_details.blank?
      end
      @billing_address=@invoice.billing_address
      @shipping_address=@invoice.shipping_address
      @invoice.last_step
      # @warehouses=@company.warehouses
      format.html {render action: "edit"}
    else
      show_validations(format)
    end
  end
  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    @port_codes = ExportPortCode.all
    @invoice = Invoice.update_invoice(params, @company, @current_user, @financial_year.year.name)
    @port_codes = ExportPortCode.all
    respond_to do |format|
        if @invoice.current_step=="first"
          if @invoice.draft?
            save_as_draft(format)
          elsif !@invoice.has_batch_products_included? && (!@company.has_more_than_one_warehouses? || !@invoice.has_atleast_one_inventoriable_item?) || @invoice.so_invoice?
            save_as_final(format)
          else
            validate_first_and_go_to_next_step(format)
          end
        else
          if @invoice.draft?
            save_as_draft(format)
          else
            save_as_final(format)
          end
        end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    # @company.invoices returns all the invoice except drafts. User should allowed to delete any invoice thats why fetching invoice using find_by_id_and_company_id
    @invoice = Invoice.find_by_id_and_company_id(params[:id], @company)
    @invoice.delete
    respond_to do |format|
      @invoice.register_delete_action(request.remote_ip, @current_user, 'deleted')
      format.html { redirect_to(invoices_url, :notice => "Invoice has been successfully deleted.") }
      format.xml  { head :ok }
    end
  end

  def add_warehouse_detail_row
    @warehouses=@company.warehouses
    @sales_warehouse_detail=SalesWarehouseDetail.new(:product_id=>params[:product_id], :warehouse_id=>@warehouses.first.id)
  end

  def remove_warehouse_detail_row
  end

  def add_row
    @invoice_line_item = InvoiceLineItem.new
    2.times{ @invoice_line_item.invoice_taxes.build }
    @from_accounts = Product.get_sales_products(@company.id)
    @products = Product.get_sales_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = InvoiceLineItem.new
    @tax_accounts = TransactionType.fetch_from_accounts(@company, 'tax')
    respond_to do |format|
      format.js
    end
  end
  def add_shipping_row
    @shipping_line_item = InvoiceLineItem.new
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    respond_to do |format|
      format.js
    end
  end
  def add_time_row
    @time_line_item = InvoiceLineItem.new
    @time_line_item.invoice_taxes.build
    @time_accounts = Task.where(:company_id => @company.id, :billable => true)
    respond_to do |format|
      format.js
    end
  end

  def batch_number_details
    stock=Stock.find_by_product_id_and_warehouse_id(params[:product_id].to_i, params[:warehouse_id].to_i)
    @batches= stock.blank? ? [] : stock.get_batches
  end

  def create_invoice_email
    @invoice = @company.invoices.find(params[:id])
  end

  def email_invoice
    template=Invoice.get_template(@company, "Invoice", "no")
    invoice = @company.invoices.find(params[:id])
    custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Invoice", true)
    invoice_line_items = invoice.invoice_line_items
    time_line_items = invoice.time_line_items
    tax_line_items = invoice.tax_line_items.group(:account_id)
    shipping_line_items = invoice.shipping_line_items
    receipt_vouchers = invoice.invoices_receipts

    @templates = CompanyTemplate.where(:voucher_type => "Invoice", :company_id=>@company.id).first
    @margin = TemplateMargin.find_by_template_id_and_company_id(@templates.template_id,@company.id)

    mail_to = params[:email]
    mail_to =mail_to.gsub(/\s+/, " ").strip
    cc = params[:cc]
    subject = params[:subject]
    text = params[:text]
    @email_valid = validate_email?(mail_to+','+cc)

    if @email_valid
      pdf = InvoicePdf.new(invoice, view_context, template, @margin, custom_field, invoice_line_items, time_line_items, shipping_line_items, tax_line_items, receipt_vouchers, 'Original')
      attachment=pdf.render
      Email.send_invoice(attachment, invoice, @company, @current_user, subject, text, mail_to, cc).deliver
      invoice.create_invoice_history(invoice.id,@company.id,@current_user.id,"sent to #{mail_to}")
      flash[:success] = 'Email has been sent successfully.'
    else
      flash[:error]='Email is either blank or invalid. If you have entered multiple emails please separate them with commas and not more than 6 emails are allowed'
    end
  end

  def instamojo_payment
   invoice = @company.invoices.find(params[:id])
   @key_active=InstamojoPayments.where(:company_id => @company.id).order("created_at desc").limit(1)
   @key_active.each do |key|
    @apikey = key.api_key
    @authkey=key.auth_key
  end
  @entries_valid = validate_entries?(params)
  if @entries_valid
    InstamojoPaymentLink.create_new(params,@apikey,@authkey,@company,request.remote_ip)
    invoice.create_invoice_history(invoice.id,@company.id,@current_user.id,"generated Instamojo payment link for #{invoice.invoice_number}")
    invoice.register_link_action(request.remote_ip,@current_user.id,"generated Instamojo payment link for")
  end
  respond_to do |format|
    format.js { render :instamojo_payment }
  end

end


def validate_entries?(params)
  if params[:email]!="" || params[:phone]!=""
    result = true
  else
    result =false
  end
  return result
end


def cashfree_payment
 invoice = @company.invoices.find(params[:id])
 @cflink_history= invoice.cashfree_payment_links.last
 @cashfree_key_active=CashFreeSetting.where(:company_id => @company.id).order("created_at desc").limit(1)
 @cashfree_key_active.each do |key|
  @appid = key.app_id
  @secretkey= key.secret_key
end
@entries_valid = validate_entries?(params)
if @entries_valid && !@cflink_history
  @cashfreelink=CashfreePaymentLink.create_new(params,@appid,@secretkey,@company,request.remote_ip)
  invoice.create_invoice_history(invoice.id,@company.id,@current_user.id,"generated CashFree payment link for #{invoice.invoice_number}")
  invoice.register_link_action(request.remote_ip,@current_user.id,"generated CashFree payment link for")
else
  @cashfreelink=CashfreePaymentLink.update(params,@appid,@secretkey,@company,request.remote_ip)
  invoice.create_invoice_history(invoice.id,@company.id,@current_user.id,"updated CashFree payment link for #{invoice.invoice_number}")
  invoice.register_link_action(request.remote_ip,@current_user.id,"updated CashFree payment link for")
end
respond_to do |format|
  format.js { render :cashfree_payment }
end

end




def restore_invoice
  @invoice = @company.invoices.find(params[:id])
  @invoice.fin_year = @financial_year.year.name
  respond_to do |format|
    if @invoice.restore(@current_user.id)
      @invoice.register_user_action(request.remote_ip, 'restored')
      format.html { redirect_to(invoices_url, :notice => "Invoice has been successfully restored") }
      format.xml  { head :ok }
    else
      @search = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
      @invoices = @search.order("invoice_date DESC").page(params[:page]).per(20)
      flash[:error] = "The invoice was not restored due to an error."
      format.html { redirect_to(invoices_deleted_invoice_url) }

    end
  end
end

  #Hard delete invoice
  def permanent_delete_invoice
    @invoice = @company.invoices.find(params[:id])
    respond_to do |format|
      if @invoice.destroy
        @invoice.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(invoices_deleted_invoice_url, :notice => "Invoice has been permanently deleted") }
        format.xml  { head :ok }
      else
        @search = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @invoices = @search.order("invoice_date DESC").page(params[:page]).per(20)
        flash[:error] = "The invoice was not deleted due to an error."
        format.html { redirect_to(invoices_deleted_invoice_url)}
      end
    end
  end
 #ware house items
 def item_from_warehouses
  @warehouses = @company.warehouses
  respond_to do |format|
      format.html {render :layout => false} # show.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  def get_quantity
   product_id = Product.find_by_account_id(params[:account_id])
   @stock = Stock.find_by_product_id_and_warehouse_id(product_id.id, params[:warehouse_id])
   respond_to do |format|
    format.js
  end
end

def remove_tax_item
    #we just want this method to pass to the erb
  end

  def remove_line_item
   #we just want this method to pass to the erb
  end
  def remove_shipping_item
    #we just want this method to pass to the erb
  end
  def remove_time_item
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
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
    end
  end

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id].to_i, @company.id)
    @stocks = @product.stocks unless @product.blank? || !@company.plan.is_inventoriable?
  end

  def set_tax
  end

  def select_warehouse
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
    @stocks = @product.stocks unless @product.blank?
  end

  def take_warehouse_quantity
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
    @stocks = @product.stocks unless @product.blank?
  end

  def create_stock
  end

  def add_product
  end

  def stop_recursion
    @invoice = @company.invoices.find_by_id(params[:id])
    @invoice.fin_year = @financial_year.year.name
    @invoice.recursion.update_attributes(:status => false)
    redirect_to @invoice, :notice => "Recursion was stoped successfully"
  end

  def start_recursion
    @invoice = @company.invoices.find_by_id(params[:id])
    @invoice.fin_year = @financial_year.year.name
    @invoice.recursion.update_attributes(:status => true)
    redirect_to @invoice, :notice => "Recursion was started successfully"
  end

  def customer_pricing
    @customer = Customer.find_by_company_id_and_name(@company.id,params[:account_name])
    @date =  params[:date].to_date
  end

  def add_payment
    @invoice = @company.invoices.find_by_id(params[:id])
    @receipt_voucher = ReceiptVoucher.create_receipt(params, @company.id, @current_user, @financial_year.year.name)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_accounts = Product.get_sales_products(@company.id)
    @payment_detail = ReceiptVoucher.fetch_payment_details(params)
  end

  def settle
    @invoice = @company.invoices.find(params[:id])
    @invoice.assign_attributes(:invoice_status_id=>3, :settlement_exchange_rate=>params[:settlement_exchange_rate], :settlement_account_id=>params[:settlement_account_id])
    if @invoice.valid?
      @invoice.update_status_and_create_adjustment_ledger_entries
    end
  end

  def customer_details
    account = @company.accounts.find_by_name(params[:account_name])
    if account.present? && (['SundryDebtor', 'SundryCreditor'].include?(account.accountable_type))
      @customer = account.customer.blank? ? account.vendor : account.customer
      @billing_address = @customer.billing_address
      @shipping_address = @customer.shipping_address
      @gstin = @customer.gstn_id
    end  
    respond_to do |format|
      format.js
    end
  end

  private
    def record_not_found
      flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
      redirect_to :action=> :index
    end
end



