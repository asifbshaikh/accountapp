class StockWastageVouchersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /stock_wastage_vouchers
  # GET /stock_wastage_vouchers.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => StockWastageVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /stock_wastage_vouchers/1
  # GET /stock_wastage_vouchers/1.xml
  def show
    @stock_wastage_voucher = @company.stock_wastage_vouchers.find(params[:id])
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockWastageVoucher")
    respond_to do |format|
      format.pdf do
        pdf=StockWastagePdf.new(view_context, @stock_wastage_voucher,@company)
        send_data pdf.render, :filename=>"#{@stock_wastage_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.html # show.html.erb
      format.xml  { render :xml => @stock_wastage_voucher }
    end
  end

  # GET /stock_wastage_vouchers/new
  # GET /stock_wastage_vouchers/new.xml
  def new
    @stock_wastage_voucher = StockWastageVoucher.new_stock_wastage(@company)

    @wastage_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockWastageVoucher")
    @destination_warehouses = @company.warehouses
    @products = Product.where(:company_id => @company.id, :inventory => true)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_wastage_voucher }
    end
  end

  # GET /stock_wastage_vouchers/1/edit
  def edit
    @stock_wastage_voucher = @company.stock_wastage_vouchers.find(params[:id])
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockWastageVoucher")
  end

  # POST /stock_wastage_vouchers
  # POST /stock_wastage_vouchers.xml
  def create
    @stock_wastage_voucher = StockWastageVoucher.create_stock_wastage(params, @company.id, @current_user, @financial_year.year.name)

    respond_to do |format|
      if @stock_wastage_voucher.save
        @stock_wastage_voucher.set_inventory
        @stock_wastage_voucher.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@stock_wastage_voucher, :notice => 'Stock wastage voucher was successfully created.') }
        format.xml  { render :xml => @stock_wastage_voucher, :status => :created, :location => @stock_wastage_voucher }
      else
        @destination_warehouses = @company.warehouses
        @wastage_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockWastageVoucher")
        @products = Product.where(:company_id => @company.id, :inventory => true)
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_wastage_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stock_wastage_vouchers/1
  # PUT /stock_wastage_vouchers/1.xml
  def update
    @stock_wastage_voucher = @company.stock_wastage_vouchers.find(params[:id])
    @stock_wastage_voucher.fin_year = @financial_year.year.name
    respond_to do |format|
      if @stock_wastage_voucher.update_attributes(params[:stock_wastage_voucher])
        format.html { redirect_to(@stock_wastage_voucher, :notice => 'Stock wastage voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockWastageVoucher")
        @products = Product.where(:company_id => @company.id, :inventory => true)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_wastage_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_wastage_vouchers/1
  # DELETE /stock_wastage_vouchers/1.xml
  def destroy
    @stock_wastage_voucher = @company.stock_wastage_vouchers.find(params[:id])
    @stock_wastage_voucher.destroy
    @stock_wastage_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')


    flash[:success] = 'Voucher was deleted successfully'
    respond_to do |format|
      format.html { redirect_to(stock_wastage_vouchers_url) }
      format.xml  { head :ok }
    end
  end
  def get_product_batches
    @product = @company.products.find params[:product_id]
    @warehouse = Warehouse.find params[:warehouse_id]
    @product_batches = ProductBatch.where(:product_id => params[:product_id],
      :warehouse_id => params[:warehouse_id])
  end
  def add_row
    @stock_wastage_line_item = StockWastageLineItem.new
    @products = Product.where(:company_id => @company.id, :inventory => true)
    respond_to do |format|
      format.js
    end
  end

  def remove_line_item

  end
  def select_product
    @products = Product.where(:company_id => @company.id, :inventory => true)
  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to  products_path(:anchor=>'stock-wastage-tab')
  end
end
