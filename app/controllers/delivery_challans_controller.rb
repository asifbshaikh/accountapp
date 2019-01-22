class DeliveryChallansController < ApplicationController
  # GET /delivery_challans
  # GET /delivery_challans.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => DeliveryChallanDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  # GET /delivery_challans/1
  # GET /delivery_challans/1.json
  def show
    @delivery_challan = DeliveryChallan.find(params[:id])
    @delivery_challan_line_items = @delivery_challan.delivery_challan_line_items
    @sales_order_line_items = @delivery_challan.sales_order.sales_order_line_items

    respond_to do |format|
      format.html
      format.xls
      format.pdf do 
        pdf=DeliveryChallanPdf.new(view_context, @company, @delivery_challan)
        send_data pdf.render, :filename=>"#{@delivery_challan.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      # prawnto :filename => "#{@delivery_challan.voucher_number}.pdf"
    end
  end

  # GET /delivery_challans/new
  # GET /delivery_challans/new.json
  def new
    @sales_order = @company.sales_orders.find_by_id(params[:sales_order_id])
    @delivery_challan = DeliveryChallan.new_delivery_challan(@company, @sales_order)
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 20)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @delivery_challan }
    end
  end

  # GET /delivery_challans/1/edit
  def edit
    @delivery_challan = DeliveryChallan.find(params[:id])
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 20)
  end

  # POST /delivery_challans
  # POST /delivery_challans.json
  def create
    @sales_order = @company.sales_orders.find_by_id(params[:sales_order_id])
    @delivery_challan = DeliveryChallan.create_delivery_challan(params, @company,  @financial_year ,@current_user, @sales_order)
    respond_to do |format|
      if @delivery_challan.valid?
        if params[:invoice].blank?
          @delivery_challan.save_with_inventory
        else
          @delivery_challan.save_with_invoice
        end
        @delivery_challan.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to(@delivery_challan.sales_order, :notice => 'Delivery challan was successfully created.')}
        format.json { render :json => @delivery_challan, :status => :created, :location => @delivery_challan }
      else
        @sales_order = @company.sales_orders.find_by_id(params[:sales_order_id])
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 20)
        format.html { render :action => "new" }
        format.json { render :json => @delivery_challan.errors, :status => :unprocessable_entity}
      end
    end
  end

  # PUT /delivery_challans/1
  # PUT /delivery_challans/1.json
  def update
    @delivery_challan = DeliveryChallan.find(params[:id])

    respond_to do |format|
      if @delivery_challan.update_attributes(params[:delivery_challan])
        @delivery_challan.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to @delivery_challan, :notice => 'Delivery challan was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @delivery_challan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_challans/1
  # DELETE /delivery_challans/1.json
  def destroy
    @delivery_challan = DeliveryChallan.find(params[:id])
    @delivery_challan.delete(request.remote_ip, @current_user)
    # @delivery_challan.destroy
    # @delivery_challan.register_user_action(request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to @delivery_challan.sales_order }
      format.json { head :ok }
    end
  end
    def get_product_batches
    @product = @company.products.find params[:product_id]
    @warehouse = Warehouse.find params[:warehouse_id]
    @product_batches = ProductBatch.where(:product_id => params[:product_id],:warehouse_id => params[:warehouse_id])
  end

end
