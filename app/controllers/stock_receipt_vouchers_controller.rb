class StockReceiptVouchersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # GET /stock_receipt_vouchers
  # GET /stock_receipt_vouchers.xml
  def index
    @stock_transfer_vouchers = @company.stock_transfer_vouchers.by_branch_id(@current_user.branch_id).by_date(@financial_year)
    @stock_wastage_vouchers = @company.stock_wastage_vouchers.by_branch_id(@current_user.branch_id).by_date(@financial_year)
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => StockReceiptVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /stock_receipt_vouchers/1
  # GET /stock_receipt_vouchers/1.xml
  def show
    @stock_receipt_voucher = @company.stock_receipt_vouchers.find(params[:id])
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockReceiptVoucher")
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=StockReceiptPdf.new(view_context, @stock_receipt_voucher,@company)
        send_data pdf.render, :filename=>"#{@stock_receipt_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.xml  { render :xml => @stock_receipt_voucher }
    end
  end

  # GET /stock_receipt_vouchers/new
  # GET /stock_receipt_vouchers/new.xml
  def new
    @stock_receipt_voucher = StockReceiptVoucher.new_stock_receipt(@company)

    @receipt_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockReceiptVoucher")
    # @warehouses = @company.warehouses
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @users = @company.users
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_receipt_voucher }
    end
  end

  # GET /stock_receipt_vouchers/1/edit
  def edit
    @stock_receipt_voucher = @company.stock_receipt_vouchers.find(params[:id])
    @warehouses = Warehouse.find_by_company(@company)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @users = @company.users
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockReceiptVoucher")
  end

  # POST /stock_receipt_vouchers
  # POST /stock_receipt_vouchers.xml
  def create
    @stock_receipt_voucher = StockReceiptVoucher.create_stock_receipt(params, @company.id, @current_user, @financial_year.year.name)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    respond_to do |format|
      if @stock_receipt_voucher.save_inventory
        # ProductBatch.record_batch(params, @stock_receipt_voucher)
        @stock_receipt_voucher.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@stock_receipt_voucher, :notice => 'Stock receipt voucher was successfully created.') }
        format.xml  { render :xml => @stock_receipt_voucher, :status => :created, :location => @stock_receipt_voucher }
      else
        @issue_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_receipt_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stock_receipt_vouchers/1
  # PUT /stock_receipt_vouchers/1.xml
  def update
    @stock_receipt_voucher = StockReceiptVoucher.update_stock_receipt(params, @current_user, @financial_year.year.name)
    respond_to do |format|
      @stock_receipt_voucher.attributes=params[:stock_receipt_voucher]
      @stock_receipt_voucher.record_batch
      if @stock_receipt_voucher.valid?
        @stock_receipt_voucher.save!
        unless @company.inventory_setting.purchase_effects_inventory? || @stock_receipt_voucher.purchase.blank?
          purchase = @stock_receipt_voucher.purchase
          purchase.fin_year = @financial_year.year.name
          purchase.manage_stock_status
        end
        @stock_receipt_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@stock_receipt_voucher, :notice => 'Stock receipt voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockReceiptVoucher")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_receipt_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_receipt_vouchers/1
  # DELETE /stock_receipt_vouchers/1.xml
  def destroy
    @stock_receipt_voucher = @company.stock_receipt_vouchers.find(params[:id])
    @stock_receipt_voucher.stock_receipt_line_items.each do |line_item|
      @stock = Stock.where(:company_id => @stock_receipt_voucher.company_id, :product_id => line_item.product_id, :warehouse_id => @stock_receipt_voucher.warehouse_id).first
      @received_quantity = line_item.quantity
    end
    if !@stock.blank? && @stock.quantity < @received_quantity
     flash[:error] = "Voucher can not be deleted. If you delete this entry your inventory will be negative, please check your entry."
    elsif !@stock.blank?
      @stock_receipt_voucher.destroy
      unless @company.inventory_setting.purchase_effects_inventory?
        purchase = @stock_receipt_voucher.purchase
        purchase.fin_year = @financial_year.year.name
        purchase.manage_stock_status
      end
      @stock_receipt_voucher.register_delete_action(request.remote_ip, @current_user, "deleted")
      flash[:success] = "Successfully deleted."
    end
    respond_to do |format|
      format.html { redirect_to(stock_receipt_vouchers_url) }
      format.xml  { head :ok }
    end
  end

  def add_row
    @stock_receipt_line_item = StockReceiptLineItem.new
    @products = Product.find_by_company(@company)
    respond_to do |format|
      format.js
    end
  end

  def batch_number_details
    @product = @company.products.find(params[:product_id])
  end
private
    def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to  products_path(:anchor=>'stock-receipt-tab')
  end

end
