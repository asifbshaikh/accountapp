class GstrAdvanceReceiptsController < ApplicationController
  #GET /gstr_advance_receipts
  #GET /gstr_advance_receipts.json
  def index
    #@customers = @company.customers.select("id, name").to_json

    respond_to do |format|

       format.json  { render :json => GstrAdvanceReceiptDatatable.new(view_context, @company, @current_user, @financial_year) }

      format.html #index.html.erb
     

     
      #format.json  { render :json => IncomeVouchersDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /gstr_advance_receipts/1
  # GET /gstr_advance_receipts/1.json
  def show
    @currency= @company.currency_code
    @gstr_advance_receipt = @company.gstr_advance_receipts.find(params[:id])
    @gstr_advance_receipt_line_items= @gstr_advance_receipt.gstr_advance_receipt_line_items
    @tax_line_items= @gstr_advance_receipt.tax_line_items.group(:account_id)
    @shipping_line_items=@gstr_advance_receipt.shipping_line_items


    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        GstrAdvanceReceipt.create_gstr_advance_receipt_history(@gstr_advance_receipt.id,@company.id,@current_user.id, "printed")
        pdf=GstrAdvanceReceiptPdf.new(@gstr_advance_receipt, view_context, @gstr_advance_receipt_line_items,@tax_line_items, @shipping_line_items)
        send_data pdf.render, :filename=>"#{@gstr_advance_receipt.voucher_number}.pdf", :disposition=>"inline", :type=>'application/pdf'
     end
     format.xml { render xml: @gstr_advance_receipt }
     if params[:print]=="yes"
      GstrAdvanceReceipt.create_gstr_advance_receipt_history(@gstr_advance_receipt.id, @company.id,@current_user.id,"printed")
    end
  end
end
  # GET /gstr_advance_receipts/new
  # GET /gstr_advance_receipts/new.json


  def new
    @gstr_advance_receipt = GstrAdvanceReceipt.new_gstr_advance_receipt(params,@company,@current_user)
    @voucher_setting=VoucherSetting.find_by_voucher_type(25,@company.id)
    @customer_id= Customer.find_by_company_id(@company.id)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
    @deposit_to = TransactionType.fetch_to_accounts(@company.id,'receipts')
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id)
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @vendor_id= Vendor.find_by_company_id(@company.id)
    @products= Product.get_sales_products(@company.id)
    @states = State.where(country_id: 93)

    #@gstr_advance_receipt_voucher_sequence= VoucherSetting.next_gstr_advance_receipt_number(@company)
   @gstr_advance_receipt_line_item =@gstr_advance_receipt.gstr_advance_receipt_line_items
    #@gstn_id= Vendor.find(params[:id])
    @gstr_advance_receipt.gstr_advance_receipt_line_items.each do |line_item|
      2.times{line_item.gstr_advance_receipt_taxes.build}
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gstr_advance_receipt }
    end
  end


  # GET /gstr_advance_receipts/1/edit
  

  def edit
    @gstr_advance_receipt = GstrAdvanceReceipt.find(params[:id])
    
    @gstr_advance_receipt.gstr_advance_receipt_line_items.each do |line_item|
      (2-line_item.gstr_advance_receipt_taxes.count).times{line_item.gstr_advance_receipt_taxes.build}
    end
    
    @voucher_setting=VoucherSetting.find_by_voucher_type(25,@company.id)
    @customer_id= Customer.find_by_company_id(@company.id)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
    @deposit_to = TransactionType.fetch_to_accounts(@company.id,'receipts')
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    #@custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id)
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @vendor_id= Vendor.find_by_company_id(@company.id)
    @products= Product.get_sales_products(@company.id)
    @states = State.where(country_id: 93)

  end

  

  

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
  end

  # POST /gstr_advance_receipts
  # POST /gstr_advance_receipts.json
  

  def create
    @gstr_advance_receipt = GstrAdvanceReceipt.create_gstr_advance_receipt(params, @company, @current_user, @financial_year.year.name)

    respond_to do |format|
    
      if @gstr_advance_receipt.save_with_ledgers && @gstr_advance_receipt.valid?
        
        VoucherSetting.next_gstr_advance_receipt_voucher_write(@company)
        GstrAdvanceReceipt.create_gstr_advance_receipt_history(@gstr_advance_receipt.id,@company.id,@current_user.id,"created")
        GstrAdvanceReceiptFilerWorker.perform_async(@company.id,@gstr_advance_receipt.id)
        format.html { redirect_to @gstr_advance_receipt, notice: 'Gstr advance receipt was successfully created.' }
        format.json { render json: @gstr_advance_receipt, status: :created, location: @gstr_advance_receipt }
      else
        @gstr_advance_receipt.gstr_advance_receipt_line_items.each do |line_item|
          (2-line_item.gstr_advance_receipt_taxes.size).times{line_item.gstr_advance_receipt_taxes.build}
        end
        
      @voucher_setting=VoucherSetting.find_by_company_id_and_voucher_type(@company.id,25)
      @gstr_advance_receipt.voucher_number = @voucher_setting.gstr_advance_receipt_voucher_number(@company)
      @customer_id= Customer.find_by_company_id(@company.id)
      @from_accounts = TransactionType.fetch_from_accounts(@company.id,'sales')
      @deposit_to = TransactionType.fetch_to_accounts(@company.id,'receipts')
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
      @shipping_accounts = Account.get_other_expense_accounts(@company)
      @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @sales_account_heads = AccountHead.get_sales_account(@company.id)
      @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @vendor_id= Vendor.find_by_company_id(@company.id)
      @products= Product.get_sales_products(@company.id)
      @states = State.where(country_id: 93)



        format.html { render action: "new" }
        format.json { render json: @gstr_advance_receipt.errors, status: :unprocessable_entity }
      end
    end
    end
  
  # PUT /gstr_advance_receipts/1
  # PUT /gstr_advance_receipts/1.json
  

 


def update
     @gstr_advance_receipt = GstrAdvanceReceipt.update_gstr_advance_receipt(params, @company.id, @current_user, @financial_year.year.name)
     @gstr_advance_receipt.amount = @gstr_advance_receipt.get_total_amount     
    respond_to do |format|
      logger.debug @gstr_advance_receipt.inspect
      if @gstr_advance_receipt.valid? 
        @gstr_advance_receipt.save
         
        #@gstr_advance_receipt.register_user_action(request.remote_ip)
        @gstr_advance_receipt.update_included_invoice_status
        @gstr_advance_receipt.set_amount_allocation
        @gstr_advance_receipt.update_and_post_ledgers
        GstrAdvanceReceiptFilerWorker.perform_async(@company.id,@gstr_advance_receipt.id)
        GstrOneUploadWorker.perform_async(@company_id, @usr_ip_addr,@gstr_one_id)  
        format.html { redirect_to(@gstr_advance_receipt, :notice => 'Gstr advance receipt was successfully updated.') }
        format.xml  { head :ok }
      else
        
        @gstr_advance_receipt.gstr_advance_receipt_line_items.each do |line_item|
          (2-line_item.gstr_advance_receipt_taxes.size).times{line_item.gstr_advance_receipt_taxes.build}
        end
      @gstr_advance_receipt = @company.gstr_advance_receipts.find(params[:id])
      @voucher_setting=VoucherSetting.find_by_company_id_and_voucher_type(@company.id,25)
      @gstr_advance_receipt.voucher_number = @voucher_setting.gstr_advance_receipt_voucher_number(@company)
      @customer_id= Customer.find_by_company_id(@company.id)
      @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
      @deposit_to = TransactionType.fetch_to_accounts(@company.id,'receipts')
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
      @shipping_accounts = Account.get_other_expense_accounts(@company)
      @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @sales_account_heads = AccountHead.get_sales_account(@company.id)
      @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @vendor_id= Vendor.find_by_company_id(@company.id)
      @products= Product.get_sales_products(@company.id)
      @states = State.where(country_id: 93)

     

      # if !params[:back_action].blank? && params[:back_action]=="allocate"

      #   @gstr_advance_receipt=@company.gstr_advance_receipts.find(params[:id])
      #   customer=@company.accounts.find(@gstr_advance_receipt.from_account_id)
          
      #    #invoices=@company.invoices.where("id not in(?)",@gstr_advance_receipt.invoices.map { |e| e.invoice_id }).by_deleted(false).by_status(0).by_customer(@gstr_advance_receipt.from_account_id).by_currency(@gstr_advance_receipt.currency_id)
      #     #invoices.map { |invoice| @gstr_advance_receipt.gstr_advance_receipt_invoices.build(:invoice_id=>invoice.id, :amount=>nil)}
        
      #     @allocated_invoices=@gstr_advance_receipt.gstr_advance_receipt_invoices

      #     @unallocated_invoices=@company.invoices.not_in(@allocated_invoices).by_deleted(false).by_status(0).by_customer(@gstr_advance_receipt.from_account_id).by_currency(@gstr_advance_receipt.currency_id)
      #     format.html { render :action=>"allocate" }
      #   else

   
          format.html { render :action => "edit" }
          format.xml  { render :xml => @gstr_advance_receipt.errors, :status => :unprocessable_entity }
      
    end
  end
end
  # DELETE /gstr_advance_receipts/1
  # DELETE /gstr_advance_receipts/1.json
  

  def destroy
    @gstr_advance_receipts = GstrAdvanceReceipt.find_by_id_and_company_id(params[:id], @company.id)
    @gstr_advance_receipts.delete_gstr_one_entry  
    @gstr_advance_receipts.delete
    respond_to do |format|
      @gstr_advance_receipts.register_delete_action(request.remote_ip, @current_user, 'deleted')
      format.html { redirect_to(gstr_advance_receipts_url, :notice =>"Gstr Advance Receipt has been succesfully deleted") }
      format.xml  {head :ok}
      
    end
  end





  



 def add_row
    @gstr_advance_receipt_line_item = GstrAdvanceReceiptLineItem.new
    2.times {@gstr_advance_receipt_line_item.gstr_advance_receipt_taxes.build}
    @products = Product.get_sales_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  
  def add_tax_row
    @tax_line_item = GstrAdvanceReceiptLineLineItem.new
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end
  

  def customer_address

    account = @company.accounts.find_by_name("#{params[:customer_name]}")
    unless account.blank?
      @customer=account.customer.blank? ? account.vendor : account.customer
    end
  end

  
  def add_shipping_row
    @shipping_line_item = GstrAdvanceReceiptLinetLineItem.new
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    respond_to do |format|
      format.js
    end
  end
  
def create_gstr_advance_receipt_email
    current_company = @company
    @gstr_advance_receipt = @company.gstr_advance_receipts.find(params[:id])
  end

  def email_gstr_advance_receipt
    @gstr_advance_receipt = @company.gstr_advance_receipts.find(params[:id])
    @gstr_advance_receipt_line_items = @gstr_advance_receipt.gstr_advance_receipt_line_items
    @tax_line_items = @gstr_advance_receipt.tax_line_items.group(:account_id)
    @shipping_line_items = @gstr_advance_receipt.shipping_line_items
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "gstr_advance_receipt", true)
    to_email = params[:email]
    subject = params[:subject]
    text = params[:text]
    pdf=GstrAdvanceReceiptPdf.new(@gstr_advance_receipt, view_context, @gstr_advance_receipt_line_items, @tax_line_items, @shipping_line_items)
    attachment=pdf.render
    if !params[:email].blank?
      Email.send_gstr_advance_receipt(attachment, @gstr_advance_receipt, @current_company, @current_user, subject, text, to_email).deliver
      gstr_advance_receipt.create_gstr_advance_receipt_history(@gstr_advance_receipt.id,@company.id,@current_user.id,"sent to #{to_email}")
      flash[:success] = 'Email has been sent successfully.'
    else
      flash[:error]='Email can not be blank'
    end
  end
  
 

  def save_as_draft(format)
    @gstr_advance_receipt.save(:validate=>false)
    format.html {redirect_to gstr_advance_receipt_path(:anchor=>"draft-gstr_advance_receipt-tab"), :notice=>"Gstr Advance receipt has been saved in draft"}
  end

  def allocate
    @gstr_advance_receipt = @company.gstr_advance_receipts.find(params[:id])
    
  #   logger.debug @gstr_advance_receipt
     @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
  #   customer = @company.accounts.find(@gstr_advance_receipt.from_account_id)
  #   #@invoices=@gstr_advance_receipt.from_account.invoices.not_in(@gstr_advance_receipt.invoices).by_status(0)
  #  # 
  #  @allocated_invoices=@gstr_advance_receipt.gstr_advance_receipt_invoices
  #  @unallocated_invoices=@company.invoices.not_in(@allocated_invoices).by_deleted(false).by_status(0).by_customer(@gstr_advance_receipt.from_account_id).by_currency(@gstr_advance_receipt.currency_id)
  #  @unallocated_invoices.map { |invoice| @gstr_advance_receipt.gstr_advance_receipt_invoices.build(:invoice_id=>invoice.id,:amount=>nil)}
    
      
  #   logger.debug @unallocated_invoices.inspect
   end




 def create_allocation
    @gstr_advance_receipt = GstrAdvanceReceipt.create_allocation(params, @company)
    #logger.debug "adv_payment values #{@adv_payment.inspect}"
    respond_to do |format|
      if @gstr_advance_receipt.save
        # @gstr_advance_payment.manage_purchase_and_gstr_advance_payment_status
        # @gstr_advance_payment.manage_gstr_advance_payment_status
        format.html { redirect_to gstr_advance_reeipt_path(@gstr_advance_receipt), :notice => 'Advance   Receipt was successfully created.'}
      else
        format.html { render :action=>"allocate"}
      end
    end
  end



  def fetch_line_items
    invoice = @company.invoices.find(params[:id])
    @line_item_details=invoice.invoice_line_items
    
  end  

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end


  def save_as_final(format)
    # @gstr_advance_payment = GstrAdvancePayment.update_purchase(params, @company, @current_user, @financial_year.year.name)
    if @gstr_advance_receipt.save_and_manage_inventory #@gstr_advance_payment.valid?
      @gstr_advance_receipt.update_and_post_ledgers
      @gstr_advance_receipt.update_gstr_advance_receipt_status
      @gstr_advance_receipt.register_user_action(request.remote_ip, "updated")
      format.html { redirect_to(@gstr_advance_receipt, :notice => 'gstr_advance_receipt was successfully updated.') }
      format.xml  { head :ok }
    else
      @gstr_advance_receipt.gstr_advance_receipt_line_items.each do |line_item|
        (2 - line_item.gstr_advance_preceipt_taxes.size).times{line_item.gstr_advance_receipt_taxes.build}
      end
      @projects = @company.projects.where(:status => false)
      @from_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
      @to_accounts = Product.get_purchase_products(@company.id)
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
      @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
      @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
      @projects = @company.projects.where(:status => false)
      @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @warehouses=@company.warehouses
      format.html { render :action => "edit" }
      format.xml  { render :xml => @gstr_advance_payment.errors, :status => :unprocessable_entity }
    end
  end



   
end
