class PurchasesController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /purchases
  # GET /purchases.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => PurchaseDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def unpaid
    @search = @company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).by_status(0).search(params[:search])
    @purchases = @search.order("record_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    @users = @company.users
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
    end
 end
 def paid
   @search = @company.purchases.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).by_status(1).search(params[:search])
    @purchases = @search.order("record_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    @users = @company.users
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
    end
 end

  def deleted_purchase
    @search = @company.purchases.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @purchases = @search.order("record_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
    end
  end
  # GET /purchases/1
  # GET /purchases/1.xml
  def show
    @company = @company
    @purchase = @company.purchases.find(params[:id])
    @purchase_attachment = PurchaseAttachment.where('purchase_id=?',@purchase.id)
    @projects = @company.projects.where(:status => false)
    @payment_vouchers = @purchase.purchases_payments
    @purchase_line_items = @purchase.purchase_line_items
    @tax_line_items = @purchase.tax_line_items.group(:account_id)
    @other_charge_line_items = @purchase.other_charge_line_items
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Purchase", true)
    @payment_voucher = PaymentVoucher.new_payment(params, @company)
    @payment_voucher.purchase_id = @purchase.id
    @payment_voucher.to_account_id = @purchase.account_id
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    @income_accounts=@company.accounts.by_accountable_type("IndirectIncomeAccount")
    @gst_debit_note = @purchase.gst_debit_note 
    respond_to do |format|
      format.html # show.html.erb
      # format.pdf {render :layout => false}
      format.pdf do
        pdf = PurchasePdf.new(@view_context, @purchase)
        send_data pdf.render, :filename=>"#{@purchase.purchase_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.xml  { render :xml => @purchase }
      prawnto :filename => "#{@purchase.purchase_number}.pdf"
    end
  end

  # GET /purchases/new
  # GET /purchases/new.xml
  def new
    @purchase = Purchase.new_purchase(params, @company, @current_user, request.remote_ip)
    @purchase.purchase_line_items.each do |line_item|
      2.times{line_item.purchase_taxes.build}
    end
    respond_to do |format|
      format.html { redirect_to edit_purchase_path(@purchase) }
      format.xml  { render :xml => @purchase }
    end
  end

# method toconvert PO into Purchase
  def po_to_purchase
    @purchase_order = @company.purchase_orders.find_by_id(params[:purchase_order_id])
    @purchase = Purchase.copy_into_new(@purchase_order, @current_user, @company, @financial_year, request.remote_ip)
    @purchase.reload
    respond_to do |format|
      if @purchase.draft?
        format.html { redirect_to edit_purchase_path(@purchase) }
      else
        format.html { redirect_to(@purchase, :notice=>"Purchase order has been converted successfully.") }
      end
    end
  end

  # GET /purchases/1/edit
  def edit
    @purchase = Purchase.find_by_company_id_and_id(@company.id, params[:id])
    @purchase.purchase_line_items.each do |line_item|
      (2 - line_item.purchase_taxes.size).times{line_item.purchase_taxes.build}
    end
    # @purchase.first_step
    if @purchase.converted_from_po?
      @warehouses=@company.warehouses
      @purchase.last_step
      @purchase.purchase_line_items.each do |line_item|
        line_item.purchase_warehouse_details.build(:warehouse_id=>@company.default_warehouse.id,
          :product_id=>line_item.product_id) if line_item.purchase_warehouse_details.blank?
      end
    end
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
    @projects = @company.projects.where(:status => false)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'purchases')
    @to_accounts = Product.get_purchase_products(@company.id)
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)#to be discuss with mohninsh sir
    @discount_accounts = AccountHead.get_discount_accounts(@company.id)
    @purchase.old_file_size = @purchase.uploaded_file_file_size
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Purchase")
    @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @purchase }
    end
  end

  # POST /purchases
  # POST /purchases.xml
  def create
    @purchase_order = @company.purchase_orders.find_by_id(params[:purchase_order_id])
    @projects = @company.projects.where(:status => false)
    @purchase = Purchase.create_purchase(params, @company.id, @current_user, @financial_year.year.name)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Purchase")
    respond_to do |format|
      if @purchase.valid?
        @purchase.stock_receipt = false unless @company.inventory_setting.purchase_effects_inventory?
        @purchase.save_with_ledgers
        if @company.inventory_setting.purchase_effects_inventory?
          @purchase.purchase_line_items.each do |line_item|
            if line_item.inventoriable? && @company.plan.is_inventoriable?
              product = line_item.product
              line_item.purchase_warehouse_details.each do |pwd|
                if product.batch_enable?
                  # logger.info"++++ This is batch enable product"
                  pwd.update_attributes(:status_id => false)
                  Stock.increase(@company.id, product.id, pwd.warehouse_id, 0, line_item.unit_rate)
                else
                  # logger.info"++++ This is inventory enable product"
                  Stock.increase(@company.id, product.id, pwd.warehouse_id, pwd.quantity, line_item.unit_rate)
                end
              end
            end
          end
        end
        @purchase.register_user_action(request.remote_ip, 'created')
        if !@purchase_order.blank?
          PurchaseOrder.update_status(@purchase_order.id, 1)
        end
        notice = "Purchase was successfully created."
        notice += "Batch numbers are enabled for some of the purchased products. Please go to <a href='/products'>products</a> and add batch details for the product." if @purchase.batch_purchased?
        format.html { redirect_to(@purchase, :notice => notice.html_safe) }
        format.xml  { render :xml => @purchase, :status => :created, :location => @purchase }
      else
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
        @projects = @company.projects.where(:status => false)
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
        @to_accounts = Product.get_purchase_products(@company.id)
        @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
        @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
        @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        if !@purchase_order.blank?
          format.html { render :action => "po_to_purchase" }
        else
         format.html { render :action => "new" }
        end
        format.xml  { render :xml => @purchase.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchases/1
  # PUT /purchases/1.xml
  def update
    @purchase = Purchase.update_purchase(params, @company, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @purchase.current_step=='first'
        if @purchase.draft?
          save_as_draft(format)
        elsif !@company.has_more_than_one_warehouses? || !@purchase.has_atleast_one_inventoriable_item?
          save_as_final(format)
        else
          validate_first_and_go_to_next_step(format)
        end
      else
        if @purchase.draft?
          save_as_draft(format)
        else
          save_as_final(format)
        end
      end
    end
  end

  def update_itc_details

    @purchase_line_item = PurchaseLineItem.find_by_id(params[:id])
    
    if(params[:eligibility]=="Input")
      eligibility = "ip"
    elsif (params[:eligibility]=="Capital Good")
      eligibility = "cp"
    elsif (params[:eligibility]=="Input Service")
      eligibility = "is"
    else
      eligibility = "no"
    end
    @purchase_line_item.update_attributes(:eligibility => eligibility, :input_tax_percentage => params[:input_tax_percentage] )
  
respond_to do |format|
      format.html { render :action => "show", :notice => 'itc details update successfully.' }
        format.js { render "purchase_itc_update" }
    end
  end
  
  
  def settle
    @purchase = @company.purchases.find(params[:id])
    @purchase.assign_attributes(:status_id=>3, :settlement_exchange_rate=>params[:settlement_exchange_rate], :settlement_account_id=>params[:settlement_account_id], :settled_amount=>@purchase.outstanding)
    if @purchase.valid?
      @purchase.update_status_and_create_adjustment_ledger_entries
    end
  end

  def validate_first_and_go_to_next_step(format)
    if @purchase.valid?
      @purchase.status_id=2 if @purchase.original_purchase.draft?
      @purchase.purchase_line_items.each do |line_item|
        line_item.purchase_warehouse_details.build(:warehouse_id=>@company.default_warehouse.id,
          :product_id=>line_item.product_id) if line_item.purchase_warehouse_details.blank?
      end
      @warehouses=@company.warehouses
      @purchase.last_step
      format.html {render :action=>"edit"}
    else
      @purchase.purchase_line_items.each do |line_item|
        (2 - line_item.purchase_taxes.size).times{line_item.purchase_taxes.build}
      end
      @projects = @company.projects.where(:status => false)
      @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
      @to_accounts = Product.get_purchase_products(@company.id)
      @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
      @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
      @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Purchase")
      @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
      @projects = @company.projects.where(:status => false)
      @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      format.html { render :action => "edit" }
      format.xml  { render :xml => @purchase.errors, :status => :unprocessable_entity }
    end
  end
  
  def save_as_draft(format)
    @purchase.save(:validate=>false)
    format.html {redirect_to purchases_path(:anchor=>"draft-purchases-tab"), :notice=>"Purchase has been saved in draft"}
  end

  def save_as_final(format)
    # @purchase = Purchase.update_purchase(params, @company, @current_user, @financial_year.year.name)
    if  @purchase.save_and_manage_inventory #@purchase.valid?
      @purchase.update_and_post_ledgers
      @purchase.update_purchase_status
      @purchase.register_user_action(request.remote_ip, "updated")
      format.html { redirect_to(@purchase, :notice => 'Purchase was successfully updated.') }
      format.xml  { head :ok }
    else
      @purchase.purchase_line_items.each do |line_item|
        (2 - line_item.purchase_taxes.size).times{line_item.purchase_taxes.build}
      end
      @projects = @company.projects.where(:status => false)
      @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
      @to_accounts = Product.get_purchase_products(@company.id)
      @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
      @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
      @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Purchase")
      @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 5)
      @projects = @company.projects.where(:status => false)
      @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
      @warehouses=@company.warehouses
      format.html { render :action => "edit" }
      format.xml  { render :xml => @purchase.errors, :status => :unprocessable_entity }
    end
  end

  #soft delete purchase
  def destroy
    # @purchase = @company.purchases.find(params[:id])
    @purchase = Purchase.find_by_company_id_and_id(@company.id, params[:id])
    raise ActiveRecord::RecordNotFound if @purchase.blank?

    respond_to do |format|
      if !@purchase.draft?
        if @purchase.delete_and_set_po_opened_if_present
          @purchase.register_delete_action(request.remote_ip, @current_user, 'deleted')
          format.html { redirect_to(purchases_url, :notice => "Purchase has been successfully deleted") }
          format.xml  { head :ok }
        else
          flash[:error] = "There are some sales still relating to this voucher. Please delete them before deleting the voucher."
          format.html { redirect_to(@purchase) }
        end
      else
        logger.debug "=============Inside else of purchase delete========"
        Purchase.delete(@purchase.id)
        logger.debug "------------Purchase deleted is #{Purchase.find(params[:id]).inspect}"
        format.html { redirect_to(purchases_url, :notice => "Purchase has been successfully deleted") }
      end  
    end
  end
#restore purchase
  def restore_purchase
    @purchase = @company.purchases.find(params[:id])
    @purchase.fin_year = @financial_year.year.name
    respond_to do |format|
      if @purchase.restore(@current_user.id)
        if @company.inventory_setting.purchase_effects_inventory?
          @purchase.purchase_line_items.each do |line_item|
            stock = Stock.where(:company_id => @purchase.company_id, :product_id => @company.accounts.find(line_item.account_id).product.id, :warehouse_id => line_item.warehouse_id)
            Stock.increase(@purchase.company_id, @company.accounts.find(line_item.account_id).product.id, line_item.warehouse_id, line_item.quantity, line_item.unit_rate)
          end
        end
        @purchase.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(purchases_url, :notice => "Purchase has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.purchases.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @purchases = @search.order("record_date DESC").page(params[:page]).per(20)
        flash[:error] = "The purchase was not restored due to an error."
        format.html { render :action => "deleted_purchase" }
        format.xml  { render :xml => @purchase.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete purchase
  def permanent_delete_purchase
    @purchase = @company.purchases.find(params[:id])
    @purchase.register_user_action(request.remote_ip, 'deleted')
    respond_to do |format|
    if @purchase.destroy
      format.html { redirect_to(purchases_deleted_purchase_url, :notice => "Purchase has been permanently deleted") }
      format.xml  { head :ok }
    else
      @search = @company.purchases.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
      @purchases = @search.order("record_date DESC").page(params[:page]).per(20)
      flash[:error] = "The purchase was not deleted due to an error."
      format.html { render :action => "deleted_purchase" }
      format.xml  { render :xml => @purchase.errors, :status => :unprocessable_entity }
    end
    end
  end
  def add_warehouse_detail_row
    @purchase_warehouse_detail=PurchaseWarehouseDetail.new(:product_id=>params[:product_id])
    @warehouses=@company.warehouses
  end
  def add_row
    @purchase_line_item = PurchaseLineItem.new
    2.times{ @purchase_line_item.purchase_taxes.build }
    @to_accounts = Product.get_purchase_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = PurchaseLineItem.new
    @tax_accounts = TransactionType.fetch_to_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end

  def add_discount_row
    @discount_line_item = DiscountLineItem.new
    @discount_accounts = AccountHead.get_discount_accounts(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_other_charge_row
    @other_charge_line_item = InvoiceLineItem.new
    @other_charge_accounts = Account.get_other_expense_on_purchase_accounts(@company)
    respond_to do |format|
      format.js
    end
  end

  def remove_warehouse_detail_row
  end
  def remove_tax_item
  end
  def remove_line_item
  end
  def remove_discount_item
  end

  #this action will let the users download the files (after a simple authorization check)
  def get
    @purchase = @company.purchases.find_by_id(params[:id])
    if @purchase
      send_file @purchase.uploaded_file.path, :type => @purchase.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to purchases_path
    end
  end

  def add_account
    @data_account = nil
    @vendor_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
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

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
    # @warehouses = @company.warehouses if !@product.blank? && @product.inventoriable?
  end

  def select_warehouse
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
    @warehouses = @company.warehouses if @company.plan.is_inventoriable?
  end
  def take_warehouse_quantity
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id )
    @warehouses = @company.warehouses
  end

  def voucher_details
    @purchase = @company.purchases.find(params[:id])
    @purchase_line_items = @purchase.purchase_line_items
    # logger.info"@@@@ voucher = #{@purchase.id}"
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

  def delete_file
        @purchase = @company.purchases.find(params[:id])
        @purchase.uploaded_file.destroy
        @purchase.update_attributes(:uploaded_file_file_name=>"",:uploaded_file_content_type=>"",:uploaded_file_file_size=>"",:uploaded_file_updated_at=>"") 
        respond_to do |format|
         format.html { redirect_to("/purchases/#{@purchase.id}", :notice => 'Attachment successfully deleted.')  }
      
        end 

   end

 private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end


end
