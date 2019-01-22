class PurchaseReturnLineItemsController < ApplicationController
  # GET /purchase_return_line_items
  # GET /purchase_return_line_items.json
  def index
    @purchase_return_line_items = PurchaseReturnLineItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @purchase_return_line_items }
    end
  end

  # GET /purchase_return_line_items/1
  # GET /purchase_return_line_items/1.json
  def show
    @purchase_return_line_item = PurchaseReturnLineItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @purchase_return_line_item }
    end
  end

  # GET /purchase_return_line_items/new
  # GET /purchase_return_line_items/new.json
  def new
    @purchase_return_line_item = PurchaseReturnLineItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @purchase_return_line_item }
    end
  end

  # GET /purchase_return_line_items/1/edit
  def edit
    @purchase_return_line_item = PurchaseReturnLineItem.find(params[:id])
  end

  # POST /purchase_return_line_items
  # POST /purchase_return_line_items.json
  def create
    @purchase_return_line_item = PurchaseReturnLineItem.new(params[:purchase_return_line_item])

    respond_to do |format|
      if @purchase_return_line_item.save
        format.html { redirect_to @purchase_return_line_item, :notice => 'Purchase return line item was successfully created.' }
        format.json { render :json => @purchase_return_line_item, :status => :created, :location => @purchase_return_line_item }
      else
        format.html { render :action => "new" }
        format.json { render :json => @purchase_return_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_return_line_items/1
  # PUT /purchase_return_line_items/1.json
  def update
    @purchase_return_line_item = PurchaseReturnLineItem.find(params[:id])

    respond_to do |format|
      if @purchase_return_line_item.update_attributes(params[:purchase_return_line_item])
        format.html { redirect_to @purchase_return_line_item, :notice => 'Purchase return line item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @purchase_return_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_return_line_items/1
  # DELETE /purchase_return_line_items/1.json
  def destroy
    @purchase_return_line_item = PurchaseReturnLineItem.find(params[:id])
    @purchase_return_line_item.destroy

    respond_to do |format|
      format.html { redirect_to purchase_return_line_items_url }
      format.json { head :ok }
    end
  end
end
