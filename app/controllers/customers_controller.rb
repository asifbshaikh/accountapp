class CustomersController < ApplicationController
  respond_to :html, :json
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # GET /customers
  # GET /customers.json
  def index
    @customers = @company.customers.includes(:account)
    respond_to do |format|
      format.xls
      format.html # index.html.erb
      format.json { render :json => CustomerDatatable.new(view_context, @company)}
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = @company.customers.find(params[:id])
    @invoices_total = @customer.account.invoices.sum(:total_amount)
    @multicurrency = false
    if !@customer.currency.blank? and @customer.currency!= @company.country.currency_code
      @multicurrency = true
      @invoices_base_cur_total = @customer.account.invoices.sum("total_amount * exchange_rate")
      @estimates_base_cur_total = @customer.account.estimates.sum("total_amount * exchange_rate")
      @receipts_base_cur_total = @customer.account.receipt_vouchers.customer_receipt_base_cur_totals(@financial_year)
    end
    @estimates_total = @customer.account.estimates.sum(:total_amount)
    @receipts_total = @customer.account.receipt_vouchers.customer_receipt_totals(@financial_year) #.where(:received_date=>@financial_year.start_date..@financial_year.end_date).sum(:amount)

    if @customer.addresses.blank?
      @billing_address = @customer.addresses.build({:address_type=>1})
      @shipping_address = @customer.addresses.build({:address_type=>0})
    else
      @billing_address = @customer.billing_address.blank? ? @customer.addresses.build({:address_type=>1}) : @customer.billing_address
      @shipping_address = @customer.shipping_address.blank? ? @customer.addresses.build({:address_type=>0}) : @customer.shipping_address
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  def new
    if !params[:customer_id].blank?
      @customer_import_id = params[:customer_id]
      @customer = Customer.correct_customer(@customer_import_id,@company,@current_user)
      @billing_address = @customer.addresses.first
      @shipping_address = @customer.addresses.last
      @opening_balance = CustomerImport.find(@customer_import_id).opening_balance
      @customer.valid?
    else
      @customer = Customer.new
      @billing_address = @customer.addresses.build({:address_type=>1})
      @shipping_address = @customer.addresses.build({:address_type=>0})
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = @company.customers.find(params[:id])
    if @customer.addresses.blank?
      @billing_address = @customer.addresses.build({:address_type=>1})
      @shipping_address = @customer.addresses.build({:address_type=>0})
    else
      @billing_address = @customer.billing_address.blank? ? @customer.addresses.build({:address_type=>1}) : @customer.billing_address
      @shipping_address = @customer.shipping_address.blank? ? @customer.addresses.build({:address_type=>0}) : @customer.shipping_address
    end
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.create_customer(params, @company, @current_user)

    respond_to do |format|
      if @customer.save
        @customer.register_user_action(request.remote_ip, "created")
        format.html { redirect_to @customer, :notice => 'Customer was successfully created.' }
        format.js { render "create_customer" }
      else
        @customer.addresses.clear
        @billing_address = @customer.addresses.build({:address_type=>1})
        @billing_address.attributes = params[:customer][:addresses_attributes]["0"]

        @shipping_address = @customer.addresses.build({:address_type=>0})
        @shipping_address.attributes = params[:customer][:addresses_attributes]["1"]

        format.html { render :action => "new" }
        format.js { render "create_customer" }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.json
  def update
    @customer = @company.customers.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        @customer.account.update_attributes(:name=>@customer.name)
        format.js {render "address"}
        @customer.register_user_action(request.remote_ip, "updated")
        format.html { redirect_to @customer, :notice => 'Customer was successfully updated.' }
        format.json { head :ok }
      else

        if @customer.billing_address.blank? || @customer.shipping_address.blank?
          @billing_address = @customer.billing_address.blank? ? @customer.addresses.build({:address_type=>1}) : @customer.billing_address
          @shipping_address = @customer.shipping_address.blank? ? @customer.addresses.build({:address_type=>0}) : @customer.shipping_address
        else
          @billing_address = @customer.billing_address
          @shipping_address = @customer.shipping_address
        end

        # @billing_address.attributes = params[:customer][:addresses_attributes]["0"]
        # @shipping_address.attributes = params[:customer][:addresses_attributes]["1"]

        format.html { render :action => "edit" }
        format.json { head :ok }
        format.js {render "address"}
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = @company.customers.find(params[:id])
    if @customer.account.has_ledgers? || @customer.account.has_vouchers?
      flash[:error] = "There are vouchers still relating to #{@customer.account.name}. Please delete them before deleting the accounts."
      redirect_to :back
    else
      @customer.destroy
      @customer.register_delete_action(request.remote_ip, @current_user, "deleted")
      respond_to do |format|
        format.html { redirect_to customers_url, :notice=>"Customer was deleted successfully" }
        format.json { head :ok }
      end
    end
  end

  private
    def record_not_found
      flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
      redirect_to :action=> :index
    end

    def state_field

    end

end
