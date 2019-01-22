class StockWastageLineItemsController < ApplicationController
  # GET /stock_wastage_line_items
  # GET /stock_wastage_line_items.xml
  def index
    @stock_wastage_line_items = StockWastageLineItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stock_wastage_line_items }
    end
  end

  # GET /stock_wastage_line_items/1
  # GET /stock_wastage_line_items/1.xml
  def show
    @stock_wastage_line_item = StockWastageLineItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stock_wastage_line_item }
    end
  end

  # GET /stock_wastage_line_items/new
  # GET /stock_wastage_line_items/new.xml
  def new
    @stock_wastage_line_item = StockWastageLineItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_wastage_line_item }
    end
  end

  # GET /stock_wastage_line_items/1/edit
  def edit
    @stock_wastage_line_item = StockWastageLineItem.find(params[:id])
  end

  # POST /stock_wastage_line_items
  # POST /stock_wastage_line_items.xml
  def create
    @stock_wastage_line_item = StockWastageLineItem.new(params[:stock_wastage_line_item])

    respond_to do |format|
      if @stock_wastage_line_item.save
        format.html { redirect_to(@stock_wastage_line_item, :notice => 'Stock wastage line item was successfully created.') }
        format.xml  { render :xml => @stock_wastage_line_item, :status => :created, :location => @stock_wastage_line_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_wastage_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stock_wastage_line_items/1
  # PUT /stock_wastage_line_items/1.xml
  def update
    @stock_wastage_line_item = StockWastageLineItem.find(params[:id])

    respond_to do |format|
      if @stock_wastage_line_item.update_attributes(params[:stock_wastage_line_item])
        format.html { redirect_to(@stock_wastage_line_item, :notice => 'Stock wastage line item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_wastage_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_wastage_line_items/1
  # DELETE /stock_wastage_line_items/1.xml
  def destroy
    @stock_wastage_line_item = StockWastageLineItem.find(params[:id])
    @stock_wastage_line_item.destroy

    respond_to do |format|
      format.html { redirect_to(stock_wastage_line_items_url) }
      format.xml  { head :ok }
    end
  end
end
