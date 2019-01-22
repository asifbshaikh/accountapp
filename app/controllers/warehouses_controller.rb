class WarehousesController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /warehouses
  # GET /warehouses.xml
  def index
    @search = @company.warehouses.search(params[:search])
    @warehouses = @search.order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @warehouses }
    end
  end

  # GET /warehouses/1
  # GET /warehouses/1.xml
  def show
    @warehouse = Warehouse.find(params[:id])
    @stocks = Stock.where(:company_id => @company.id, :warehouse_id => params[:id]).page(params[:page]).per(20)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @warehouse }
    end
  end

  # GET /warehouses/new
  # GET /warehouses/new.xml
  def new
    @warehouse = Warehouse.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @warehouse }
    end
  end

  # GET /warehouses/1/edit
  def edit
    @warehouse = Warehouse.find(params[:id])
  end

  # POST /warehouses
  # POST /warehouses.xml
  def create
    @warehouse = Warehouse.create_warehouse(params, @company.id, @current_user.id)
    respond_to do |format|
      if @warehouse.save
        @warehouse.register_user_action(request.remote_ip, 'created')
        flash[:success] = 'Warehouse was created.'
      end
      format.js { render '/settings/create_warehouse'}
    end
  end

  # PUT /warehouses/1
  # PUT /warehouses/1.xml
  def update
    @warehouse = Warehouse.find(params[:id])
    respond_to do |format|
      if @warehouse.update_attributes(params[:warehouse])
        @warehouse.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(settings_payroll_path, :notice => 'Warehouse was successfully updated.') }
        # format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @warehouse.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@warehouse) }
      end
    end
  end

  # DELETE /warehouses/1
  # DELETE /warehouses/1.xml
  def destroy
    @warehouse = Warehouse.find(params[:id])
    if !@warehouse.has_stock_vouchers? && !@warehouse.has_inventory_vouchers? 
      @warehouse.destroy
      flash[:success]="Warehouse deleted successfully."
    else
      flash[:error] = "There are vouchers still relating to #{@warehouse.name}. Please delete them before deleting the warehouse."
    end
      respond_to do |format|
        format.html { redirect_to(settings_inventory_path) }
        format.xml  { head :ok }
      end
  end
  
  def new_batch_detail
    @product = @company.products.find_by_id(params[:product_id])
    @warehouse = Warehouse.find_by_id(params[:warehouse_id])
    @purchase_warehouse_details = PurchaseWarehouseDetail.get_batch_hold_records(@company.id, @product, @warehouse.id)
    @product_batches = ProductBatch.where(:product_id => @product.id, :warehouse_id => params[:warehouse_id])
    if @product_batches.blank?
      @product_batches<<ProductBatch.new()
    end
  end
  def add_batch_row
    @product_batch = ProductBatch.new()
    @product_batch.warehouse_id = params[:warehouse_id]
  end
  def record_batch_warehouse_details
    @warehouse = Warehouse.find params[:warehouse_id]
    @product = @company.products.find params[:product_id]
    if @product.update_attributes(params[:product])
      params[:product][:product_batches_attributes].each do |pba|
        unless params[:product][:product_batches_attributes][pba[0]][:batch_number].blank?
          reference = params[:product][:product_batches_attributes][pba[0]][:reference]
          product_batch = ProductBatch.where(:company_id => @company.id,
            :product_id => @product.id, :warehouse_id => @warehouse.id,
            :reference => reference).first
          pwd = PurchaseWarehouseDetail.find_by_id params["purchase_warehouse_id_at#{pba[0]}"]
          if !product_batch.blank? && !pwd.blank? && product_batch.quantity == pwd.quantity
            pwd.update_attributes(:status_id => true, :product_batch_id => product_batch.id)
          end
        end
        @stock = Stock.where(:company_id => @company.id, :product_id => @product.id,
          :warehouse_id => @warehouse.id).first
      end
    end
  end

 private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to settings_inventory_path
  end

end
