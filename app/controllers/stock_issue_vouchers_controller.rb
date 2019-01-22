class StockIssueVouchersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /stock_issue_vouchers
  # GET /stock_issue_vouchers.xml

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => StockIssueVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /stock_issue_vouchers/1
  # GET /stock_issue_vouchers/1.xml
  def show
    @stock_issue_voucher = @company.stock_issue_vouchers.find(params[:id])
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=StockIssuePdf.new(view_context, @stock_issue_voucher,@company)
        send_data pdf.render, :filename=>"#{@stock_issue_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.xml  { render :xml => @stock_issue_voucher }
    end
  end

  # GET /stock_issue_vouchers/new
  # GET /stock_issue_vouchers/new.xml
  def new
    @stock_issue_voucher = StockIssueVoucher.new_stock_issue(@company)

    @issue_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
    @warehouses = Warehouse.find_by_company(@company)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @users = @company.users
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_issue_voucher }
    end
  end

  # GET /stock_issue_vouchers/1/edit
  def edit
    @stock_issue_voucher = @company.stock_issue_vouchers.find(params[:id])
    @warehouses = Warehouse.find_by_company(@company)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    @users = @company.users
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
  end

  # POST /stock_issue_vouchers
  # POST /stock_issue_vouchers.xml
  def create
    @stock_issue_voucher = StockIssueVoucher.create_stock_issue(params, @company.id, @current_user, @financial_year.year.name)
    @products = Product.where(:company_id => @company.id, :inventory => true)
    respond_to do |format|
      if @stock_issue_voucher.save_inventory
        @stock_issue_voucher.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@stock_issue_voucher, :notice => 'Stock issue voucher was successfully created.') }
        format.xml  { render :xml => @stock_issue_voucher, :status => :created, :location => @stock_issue_voucher }
      else
        @issue_voucher_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_issue_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stock_issue_vouchers/1
  # PUT /stock_issue_vouchers/1.xml
  def update
    @stock_issue_voucher = StockIssueVoucher.update_stock_issue(params, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @stock_issue_voucher.update_attributes(params[:stock_issue_voucher])
        @stock_issue_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@stock_issue_voucher, :notice => 'Stock issue voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        @products = Product.find_by_company(@company)
        @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "StockIssueVoucher")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_issue_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_issue_vouchers/1
  # DELETE /stock_issue_vouchers/1.xml
  def destroy
    @stock_issue_voucher = @company.stock_issue_vouchers.find(params[:id])
    @stock_issue_voucher.destroy
    @stock_issue_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')
  	respond_to do |format|
      flash[:success] = "Voucher was deleted successfully"
      format.html { redirect_to(stock_issue_vouchers_url) }
      format.xml  { head :ok }
    end
  end

  def add_row
    @stock_issue_line_item = StockIssueLineItem.new
    @products = Product.where(:company_id => @company.id, :inventory => true)
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
private
    def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to  products_path(:anchor=>'stock-issue-tab')
  end

end
