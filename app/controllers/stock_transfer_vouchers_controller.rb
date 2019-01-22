class StockTransferVouchersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /stock_transfer_vouchers
  # GET /stock_transfer_vouchers.json
  def index
    @stock_wastage_vouchers = @company.stock_wastage_vouchers.by_branch_id(@current_user.branch_id).by_date(@financial_year)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => StockTransferVoucherDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  # GET /stock_transfer_vouchers/1
  # GET /stock_transfer_vouchers/1.json
  def show
    @stock_transfer_voucher=@company.stock_transfer_vouchers.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=StockTransferPdf.new(view_context, @stock_transfer_voucher,@company)
        send_data pdf.render, :filename=>"#{@stock_transfer_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.json { render :json => @stock_transfer_voucher }
    end
  end

  # GET /stock_transfer_vouchers/new
  # GET /stock_transfer_vouchers/new.json
  def new
    @stock_transfer_voucher = StockTransferVoucher.new_stock_transfer(@company)

    @products = Product.where(:company_id => @company.id, :inventory => true)
    @destination_warehouses = @company.warehouses
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @stock_transfer_voucher }
    end
  end

  # GET /stock_transfer_vouchers/1/edit
  def edit
    @stock_transfer_voucher = @company.stock_transfer_vouchers.find(params[:id])
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @destination_warehouses = @company.warehouses
  end

  # POST /stock_transfer_vouchers
  # POST /stock_transfer_vouchers.json
  def create
    @stock_transfer_voucher = StockTransferVoucher.create_stock_transfer(params, @company.id, @current_user, @financial_year.year.name)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @destination_warehouses = @company.warehouses
    respond_to do |format|
      if @stock_transfer_voucher.save_inventory
        @stock_transfer_voucher.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to @stock_transfer_voucher, :notice => 'Stock transfer voucher was successfully created.' }
        format.json { render :json => @stock_transfer_voucher, :status => :created, :location => @stock_transfer_voucher }
      else
        format.html { render :action => "new" }
        format.json { render :json => @stock_transfer_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stock_transfer_vouchers/1
  # PUT /stock_transfer_vouchers/1.json
  def update
    @stock_transfer_voucher = StockTransferVoucher.update_stock_transfer(params, @current_user, @financial_year.year.name)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @destination_warehouses = @company.warehouses
    respond_to do |format|
      if @stock_transfer_voucher.save_and_manage_stock(request.remote_ip)
        # @stock_transfer_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to @stock_transfer_voucher, :notice => 'Stock transfer voucher was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @stock_transfer_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_transfer_vouchers/1
  # DELETE /stock_transfer_vouchers/1.json
  def destroy
    @stock_transfer_voucher = @company.stock_transfer_vouchers.find(params[:id])
    @stock_transfer_voucher.destroy
    @stock_transfer_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')
    respond_to do |format|
      format.html { redirect_to stock_transfer_vouchers_url }
      format.json { head :ok }
    end
  end

  def add_row
    @stock_transfer_line_item = StockTransferLineItem.new
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @destination_warehouses = @company.warehouses
    respond_to do |format|
      format.js
    end
  end
  def get_product_batches
    @product = @company.products.find params[:product_id]
    @warehouse = Warehouse.find params[:warehouse_id]
    @product_batches = ProductBatch.where(:product_id => params[:product_id],
      :warehouse_id => params[:warehouse_id])
  end
 def warehouse_wise_product
  if !params[:warehouse_id].blank?
    @stock_transfer_line_item = StockTransferLineItem.new
    # @stock_transfer_voucher = StockTransferVoucher.new_stock_transfer(@company)
    @products = Product.includes("stocks").where("stocks.warehouse_id" => params[:warehouse_id], :company_id => @company.id)
    @destination_warehouses = Warehouse.where("company_id = ? and id != ?", @company.id, params[:warehouse_id])
  else
    @products = []
    @destination_warehouses = Warehouse.default_warehouse(@company.id)
  end

  respond_to do |format|
    format.js
  end
 end

  def menu_title
    @menu = 'Inventory'
    @page_name = 'Stock Transfer Voucher'
  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to  products_path(:anchor=>'stock-transfer-tab')
  end
end
