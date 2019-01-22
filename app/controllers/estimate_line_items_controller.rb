class EstimateLineItemsController < ApplicationController

  layout "application", :except => [:show]
  # GET /estimate_line_items
  # GET /estimate_line_items.xml
  def index
    @estimate_line_items = EstimateLineItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @estimate_line_items }
    end
  end

  # GET /estimate_line_items/1
  # GET /estimate_line_items/1.xml
  def show
    @estimate_line_item = EstimateLineItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @estimate_line_item }
    end
  end

  # GET /estimate_line_items/new
  # GET /estimate_line_items/new.xml
  def new
    @estimate_line_item = EstimateLineItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @estimate_line_item }
    end
  end

  # GET /estimate_line_items/1/edit
  def edit
    @estimate_line_item = EstimateLineItem.find(params[:id])
  end

  # POST /estimate_line_items
  # POST /estimate_line_items.xml
  def create
    @estimate_line_item = EstimateLineItem.new(params[:estimate_line_item])

    respond_to do |format|
      if @estimate_line_item.save
        format.html { redirect_to(@estimate_line_item, :notice => 'Estimate line item was successfully created.') }
        format.xml  { render :xml => @estimate_line_item, :status => :created, :location => @estimate_line_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @estimate_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /estimate_line_items/1
  # PUT /estimate_line_items/1.xml
  def update
    @estimate_line_item = EstimateLineItem.find(params[:id])

    respond_to do |format|
      if @estimate_line_item.update_attributes(params[:estimate_line_item])
        format.html { redirect_to(@estimate_line_item, :notice => 'Estimate line item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @estimate_line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /estimate_line_items/1
  # DELETE /estimate_line_items/1.xml
  def destroy
    @estimate_line_item = EstimateLineItem.find(params[:id])
    @estimate_line_item.destroy

    respond_to do |format|
      format.html { redirect_to(estimate_line_items_url) }
      format.xml  { head :ok }
    end
  end
end
