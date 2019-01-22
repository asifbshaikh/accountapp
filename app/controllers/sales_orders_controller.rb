class SalesOrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /sales_orders
  # GET /sales_orders.json
  def index
    # @sales_orders = SalesOrder.all
    respond_to do |format|
      format.html # index.html.erb
     format.json { render :json => SalesOrderDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

 def inventory_order

 end
  # GET /sales_orders/1
  # GET /sales_orders/1.json
  def show
    @currency = @company.currency_code
    @sales_order = @company.sales_orders.find(params[:id])
    @sales_order_line_items = @sales_order.sales_order_line_items
    @tax_line_items = @sales_order.tax_line_items.group(:account_id)
    @shipping_line_items = @sales_order.shipping_line_items
    @delivery_challans = @sales_order.delivery_challans
    @invoices = @sales_order.invoices
    respond_to do |format|
      format.html # show.html.erb
      format.pdf  {render :layout => false}
      format.xml  { render :xml => @sales_order }
      prawnto :filename => "#{@sales_order.voucher_number}.pdf"
    end
  end

  # GET /sales_orders/new
  # GET /sales_orders/new.json
  def new
    @sales_order = SalesOrder.new_sales_order(@company, @current_user, @financial_year, request.remote_ip)
    @from_accounts = Product.get_sales_products(@company.id)
    @to_accounts = @company.customers
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)

    respond_to do |format|
      format.html {redirect_to edit_sales_order_path(@sales_order)}
      format.json { render :json => @sales_order }
    end
  end

  # GET /sales_orders/1/edit
  def edit
    @sales_order = @company.sales_orders.find(params[:id])
    @sales_order.sales_order_line_items.each do |line_item|
      (2-line_item.sales_order_taxes.size).times {line_item.sales_order_taxes.build}
    end
    if @company.currency_code == 'INR'
        @sales_order.gst_salesorder = true
    end
    @from_accounts = Product.get_sales_products(@company.id)
    @to_accounts = @company.customers
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    @sales_account_heads = AccountHead.get_sales_account(@company.id)
    @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
    @projects = @company.projects.active
    @states = State.where(country_id: 93)
  end


  # POST /sales_orders
  # POST /sales_orders.json
  def create
    @sales_order = SalesOrder.create_sales_order(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @sales_order.save
         @sales_order.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to @sales_order, :notice => 'Sales order was successfully created.' }
        format.json { render :json => @sales_order, :status => :created, :location => @sales_order }
      else
        @from_accounts = Product.get_sales_products(@company.id)
        @to_accounts = @company.customers
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        format.html { render :action => "new" }
        format.json { render :json => @sales_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sales_orders/1
  # PUT /sales_orders/1.json
  def update
    @sales_order = SalesOrder.update_sales_order(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @sales_order.valid?
        @sales_order.save
        @sales_order.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        @sales_order.update_attribute("status", 1) if @sales_order.status == 4
        format.html { redirect_to @sales_order, :notice => 'Sales order was successfully updated.' }
        format.json { head :ok }
      else
        @sales_order.sales_order_line_items.each do |line_item|
          (2-line_item.sales_order_taxes.size).times {line_item.sales_order_taxes.build}
        end
        @states = State.where(country_id: 93)
        @from_accounts = Product.get_sales_products(@company.id)
        @to_accounts = @company.customers
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @shipping_accounts = Account.get_other_expense_accounts(@company)
        @customer_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        @sales_account_heads = AccountHead.get_sales_account(@company.id)
        @tax_account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
        @projects = @company.projects.active
        format.html { render :action => "edit" }
        format.json { render :json => @sales_order.errors, :status => :unprocessable_entity }
      end
    end
  end
  def cancel_order
    @sales_order = @company.sales_orders.find(params[:id])
    unless @sales_order.blank?
      @sales_order.update_attribute("status", 5)
      @sales_order.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
      redirect_to sales_orders_path, :notice => 'Sales order successfully cancelled.'
    end
  end

  # DELETE /sales_orders/1
  # DELETE /sales_orders/1.json
  def destroy
    @sales_order = @company.sales_orders.find(params[:id])
    @sales_order.fin_year = @financial_year.year.name
    respond_to do |format|
      if @sales_order.destroy
        @sales_order.estimate.update_attribute(:status, nil) unless @sales_order.estimate.blank?
        @sales_order.register_delete_action(request.remote_ip, @current_user, 'deleted', @current_user.branch_id)
        format.html { redirect_to(sales_orders_url, :notice => "Sales order has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.sales_orders.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @sales_orders = @search.order("sales_order_date DESC").page(params[:page]).per(20)
        flash[:error] = "Sales order was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @sales_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_row
    @sales_order_line_item = SalesOrderLineItem.new
    2.times{@sales_order_line_item.sales_order_taxes.build}
    @from_accounts = Product.get_sales_products(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def add_tax_row
    @tax_line_item = SalesOrderLineItem.new
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      format.js
    end
  end

  def add_shipping_row
    @shipping_line_item = SalesOrderLineItem.new
    @shipping_accounts = Account.get_other_expense_accounts(@company)
    respond_to do |format|
      format.js
    end
  end


  def remove_tax_item
  end

  def remove_line_item
  end

  def remove_shipping_item
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
      # @account_heads = nil
      @account_heads = AccountHead.get_duties_and_taxes_account(@company.id)
      @data_account = "tax"
    end

  end

  def desc_cost
    @product = Product.find_by_id_and_company_id(params[:product_id], @company.id)
  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end


end
