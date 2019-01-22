class VendorsController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /vendors
  # GET /vendors.json
  def index
    @vendors = @company.vendors.includes(:account).includes(:currency)
    respond_to do |format|
      format.xls
      format.html # index.html.erb
      format.json { render :json => VendorDatatable.new(view_context, @company) }
    end
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
    @vendor = @company.vendors.find(params[:id])
    @purchase_total = @vendor.account.purchases.sum(:total_amount)
    @purchase_orders_total = @vendor.account.purchase_orders.sum(:total_amount)
    @payments_total = @vendor.account.payment_vouchers.current_year_total(@financial_year) #where(:payment_date=> @financial_year.start_date..@financial_year.end_date).sum(:amount)
    @multicurrency = false
    if @vendor.currency_code.present? && (@vendor.currency_code != @company.currency_code)
      @multicurrency = true
      @purchase_base_cur_total = @vendor.account.purchases.sum("total_amount * exchange_rate")
      @purchase_orders_base_cur_total = @vendor.account.purchase_orders.sum("total_amount * exchange_rate")
      @payments_base_cur_total = @vendor.account.payment_vouchers.current_year_base_cur_total(@financial_year)
    end

    if @vendor.addresses.blank?
      @billing_address = @vendor.addresses.build({:address_type=>1})
      @shipping_address = @vendor.addresses.build({:address_type=>0})
    else
      @billing_address = @vendor.billing_address.blank? ? @vendor.addresses.build({:address_type=>1}) : @vendor.billing_address
      @shipping_address = @vendor.shipping_address.blank? ? @vendor.addresses.build({:address_type=>0}) : @vendor.shipping_address
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @vendor }
    end
  end

  # GET /vendors/new
  # GET /vendors/new.json
  def new
    if !params[:vendor_id].blank?
      @vendor_import_id = params[:vendor_id]
      @vendor = Vendor.correct_vendor(@vendor_import_id,@company,@current_user)
      @billing_address = @vendor.addresses.first
      @shipping_address = @vendor.addresses.last
      @opening_balance = VendorImport.find(@vendor_import_id).opening_balance
      @vendor.valid?
    else
      @vendor = Vendor.new
      @billing_address = @vendor.addresses.build({:address_type=>1})
      @shipping_address = @vendor.addresses.build({:address_type=>0})
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @vendor }
      end
    end
  end

  # GET /vendors/1/edit
  def edit
    @vendor = @company.vendors.find(params[:id])
    # @vendor.addresses.build if @vendor.addresses.blank?
    if @vendor.addresses.blank?
      @billing_address = @vendor.addresses.build({:address_type=>1})
      @shipping_address = @vendor.addresses.build({:address_type=>0})
    else
      @billing_address = @vendor.billing_address.blank? ? @vendor.addresses.build({:address_type=>1}) : @vendor.billing_address
      @shipping_address = @vendor.shipping_address.blank? ? @vendor.addresses.build({:address_type=>0}) : @vendor.shipping_address
    end
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.create_vendor(params,@company, @current_user.id)

    respond_to do |format|
      if @vendor.save
        @vendor.register_user_action(request.remote_ip, "created")
        format.html { redirect_to @vendor, :notice => 'Vendor was successfully created.' }
        format.js { render "create_vendor" }
      else
        @vendor.addresses.clear
        @billing_address = @vendor.addresses.build({:address_type=>1})
        @billing_address.attributes = params[:vendor][:addresses_attributes]["0"]

        @shipping_address = @vendor.addresses.build({:address_type=>0})
        @shipping_address.attributes = params[:vendor][:addresses_attributes]["1"]

        format.html { render :action => "new" }
        format.js { render "create_vendor" }
      end
    end
  end

  # PUT /vendors/1
  # PUT /vendors/1.json
  def update
    @vendor = @company.vendors.find(params[:id])

    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        @vendor.account.update_attributes(:name=>@vendor.name)
        format.js {render "address"}
        @vendor.register_user_action(request.remote_ip, "updated")
        format.html { redirect_to @vendor, :notice => 'Vendor was successfully updated.' }
        format.json { head :ok }
      else

        if @vendor.billing_address.blank? || @vendor.shipping_address.blank?
          @billing_address = @vendor.billing_address.blank? ? @vendor.addresses.build({:address_type=>1}) : @vendor.billing_address
          @shipping_address = @vendor.shipping_address.blank? ? @vendor.addresses.build({:address_type=>0}) : @vendor.shipping_address
        else
          @billing_address = @vendor.billing_address
          @shipping_address = @vendor.shipping_address
        end

        # @billing_address.attributes = params[:vendor][:addresses_attributes]["0"]
        # @shipping_address.attributes = params[:vendor][:addresses_attributes]["1"]

        format.html { render :action => "edit" }
         format.json { respond_with_bip(@vendor) }
        format.js {render "address"}
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor = @company.vendors.find(params[:id])
    if @vendor.account.has_ledgers? || @vendor.account.has_vouchers?
      flash[:error] = "There are vouchers still relating to #{@vendor.account.name}. Please delete them before deleting the accounts."
      redirect_to :back
    else
      @vendor.destroy
      @vendor.register_delete_action(request.remote_ip, @current_user, "deleted")
      respond_to do |format|
        format.html { redirect_to vendors_url }
        format.json { head :ok }
      end
    end
  end
   private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
