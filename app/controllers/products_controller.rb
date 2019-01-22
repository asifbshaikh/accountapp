class ProductsController < ApplicationController
  require 'date'
  require 'csv'
  require 'open-uri'
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /products
  # GET /products.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => ProductDatatable.new(view_context, @company) }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = @company.products.find(params[:id])
    @stocks = Stock.where(:company_id => @company.id, :product_id => params[:id]).page(params[:page]).per(10)
    @total_purchased = PurchaseLineItem.by_product(@product.id).by_company(@company.id).by_record_date(@financial_year.start_date, @financial_year.end_date).by_branch(@current_user.branch_id)
    @total_sold=InvoiceLineItem.by_product(@product.id).by_company(@company.id).by_invoice_date(@financial_year.start_date, @financial_year.end_date).by_branch(@current_user.branch_id)
    if @product.type.to_s == 'SalesItem' || @product.type.to_s == 'ResellerItem'
      @invoices = Invoice.by_branch_id(@current_user.branch_id).where(:company_id=>@company.id, :invoice_status_id => [0,2,3]).joins(:invoice_line_items).where(:"invoice_line_items.product_id" => @product.id).group("invoices.id").order("invoice_date DESC").limit(5)
    elsif @product.type.to_s == 'PurchaseItem'
      @purchases = Purchase.by_branch_id(@current_user.branch_id).where(:company_id=>@company.id, :status_id => [0,1,3]).
      joins(:purchase_line_items).where(:"purchase_line_items.product_id" => @product.id).group("purchases.id").
      order("record_date DESC").limit(5)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end


  def load_hsn_code
    index =  params[:page].to_i
    @code_type= params[:code_type]
    if params.has_key?(:chapter_id)
      fetch_code = params[:chapter_id].rjust(2, '0')
      @product_hsn_codes = HsnCode.where("HSN_Code like ? and code_type = ?","#{fetch_code}%",@code_type).page(params[:page]).per(params[:per])
    elsif params.has_key?(:heading_index)
      fetch_code = params[:heading_index]
      @product_hsn_codes =  HsnCode.where("HSN_Code like ? and code_type = ?","#{fetch_code}%",@code_type).page(params[:page]).per(params[:per])
    end
    @max_entry =   @product_hsn_codes.last_page? ?  @product_hsn_codes.total_count : ( @product_hsn_codes.first_page? ? 25 : (index)*25 )
    @min_entry =   @product_hsn_codes.first_page? ? 1 : (index-1)*25 + 1
  end 

  # GET /products/new
  # GET /products/new.xml
  def new
    if !params[:product_id].blank?
      @product_import_id = params[:product_id]
      @product = Product.new_product(@product_import_id,@company.id,@current_user.id)
      @product.valid?
    else
      @product = Product.new
      default_income_account=Account.get_default_income_account(@company.id)
      default_expense_account=Account.get_default_expense_account(@company.id)
      @product.income_account_id=default_income_account.id unless default_income_account.blank?
      @product.expense_account_id=default_expense_account.id unless default_expense_account.blank?
    end
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @warehouses = @company.warehouses
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    @warehouses = @company.warehouses
    @product = @company.products.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.create_product(params, @company.id, @current_user)
    respond_to do |format|
      if @product.save
        @product.enter_opening_stock(params)
        if !params[:import_product_id].blank?
          imported_product = ProductImport.find(params[:import_product_id])
          imported_product.update_attributes(:status =>1)
        end
        @product.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@product, :notice => 'Product was successfully created.') }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @warehouses = @company.warehouses
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.update_product(params, @company.id, @current_user)
    # params = Product.set_params(params)
    respond_to do |format|
      if @product.update_attributes(params[:product])
        unless params[:warehouse].blank?
          @company.warehouses.each do |warehouse|
            Stock.update_inventory(params, @company.id, @product.id, warehouse.id, params['quantity_at_'+warehouse.id.to_s])
          end
        end
        if @product.batch_enable?
          product_batches = ProductBatch.where(:product_id => @product.id, :company_id => @company.id, :reference => nil)
          stocks = []
          product_batches.each do |product_batch|
            stock = Stock.where(:company_id => @company.id, :product_id => @product.id, :warehouse_id => product_batch.warehouse_id).first
            if !stock.blank?
              if stocks.include?(stock.id)
                stock.opening_stock += product_batch.quantity
              else
                stock.opening_stock = product_batch.quantity
              end
              stock.save
              stocks<<stock.id
            end
          end
        end
        @product.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.xml  { head :ok }
      else
        @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
        @warehouses = @company.warehouses
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = @company.products.find(params[:id])
    if !@product.has_vouchers? && !@product.has_stock_vouchers?
      @product.destroy
      @product.register_delete_action(request.remote_ip, @current_user, 'deleted')
      respond_to do |format|
        format.html { redirect_to(products_url, :notice => "Product has been successfully deleted.") }
        format.xml  { head :ok }
      end
    else
      flash[:error] = "There are vouchers still relating to #{@product.name}. Please delete them before deleting the product."
      redirect_to @product
    end
  end

  def add_row
    @warehouses = @company.warehouses
  end

  def record_batch_warehouse_details

  end

  # def record_batch_details
  #   @product = @company.products.find params[:id]
  #   if @product.update_attributes(params[:product])
  #     purchase_warehouse_details = PurchaseWarehouseDetail.get_hold_product_batches(@company.id, @product.id)
  #     purchase_warehouse_details.each do |pwd|
  #       purchase = pwd.purchase_line_item.purchase
  #       batch = ProductBatch.where(:company_id=>@company.id, :product_id=>pwd.product_id, :warehouse_id=>pwd.warehouse_id, :quantity=>pwd.quantity, :reference=>purchase.purchase_number).first
  #       unless batch.blank?
  #         pwd.update_attributes(:status_id=>true, :product_batch_id=>batch.id) unless pwd.status_id?
  #       end
  #     end
  #   end
  #   @products = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem']).order("created_at DESC")
  # end


  def record_batch_details
    @product = @company.products.find params[:id]
   # @product.need_not_update_ledgers = true
   purchase_warehouse_details = PurchaseWarehouseDetail.get_hold_product_batches(@company.id, @product.id)
   purchase_warehouse_details.each_with_index do |pwd,index|
    product_id_value=params[:product][:product_batches_attributes][index.to_s][:product_id]
    warehouse_id_value=params[:product][:product_batches_attributes][index.to_s][:warehouse_id]
    batch_no_value=params[:product][:product_batches_attributes][index.to_s][:batch_number]
    quantities_value=params[:product][:product_batches_attributes][index.to_s][:quantity]
    reference_value=params[:product][:product_batches_attributes][index.to_s][:reference]
    
    batches = ProductBatch.where(:company_id=> @company.id,:product_id => product_id_value,:warehouse_id => warehouse_id_value)
    flag = true
    batches.each do |batch_value|      
      if batch_value.batch_number == batch_no_value
        quantity = batch_value.quantity + quantities_value.to_f
        
        if batch_value.reference.blank?
         reference = reference_value
       else
        reference = batch_value.reference + "," + reference_value
      end
      batch_value.update_attributes(:quantity => quantity,:reference => reference,)
      pwd.update_attributes(:status_id=>true, :product_batch_id=>batch_value.id) unless pwd.status_id?
      flag= false
    end
  end
  if flag
   batch = ProductBatch.new(:company_id => @company.id,:product_id => product_id_value, :warehouse_id => warehouse_id_value, :quantity => quantities_value, :reference => reference_value, :batch_number => batch_no_value)
   if !batch.batch_number.blank?
     batch.save!
     pwd.update_attributes(:status_id=>true, :product_batch_id=>batch.id) unless pwd.status_id?
   end
 end
end
@products = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem']).order("created_at DESC")
end


def select_warehouse
 @warehouses = @company.warehouses
 @product = @company.products.find_by_id(params[:product])
end

def take_warehouse_quantity
end

def sales_items
  @search = @company.products.where(:type => ['SalesItem', 'ResellerItem']).search(params[:search])
  @products = @search.order("created_at DESC").page(params[:page]).per(20)
    # @products = Product.where(:type => ['SalesItem', 'ResellerItem'], :company_id => @company.id).page(params[:page]).per(20)
  end

  def purchase_items
    @search = @company.products.where(:type => ['PurchaseItem', 'ResellerItem']).search(params[:search])
    @products = @search.order("created_at DESC").page(params[:page]).per(20)
    # @products = Product.where(:type => ['PurchaseItem', 'ResellerItem'], :company_id => @company.id).page(params[:page]).per(20)
  end

  def reseller_items
    @products = ResellerItem.where(:company_id => @company.id).page(params[:page]).per(20)
  end

  def all_items
    @search = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem']).search(params[:search])
    @products = @search.order("created_at DESC").page(params[:page]).per(20)
    # @products = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem']).page(params[:page]).per(20)
  end
  def manage_stock

  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
