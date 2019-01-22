class InvoiceStatusesController < ApplicationController

  layout "application", :except => [:show]
  # GET /invoice_statuses
  # GET /invoice_statuses.xml
  def index
    @invoice_statuses = InvoiceStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoice_statuses }
    end
  end

  # GET /invoice_statuses/1
  # GET /invoice_statuses/1.xml
  def show
    @invoice_status = InvoiceStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice_status }
    end
  end

  # GET /invoice_statuses/new
  # GET /invoice_statuses/new.xml
  def new
    @invoice_status = InvoiceStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice_status }
    end
  end

  # GET /invoice_statuses/1/edit
  def edit
    @invoice_status = InvoiceStatus.find(params[:id])
  end

  # POST /invoice_statuses
  # POST /invoice_statuses.xml
  def create
    @invoice_status = InvoiceStatus.new(params[:invoice_status])

    respond_to do |format|
      if @invoice_status.save
        format.html { redirect_to(@invoice_status, :notice => 'Invoice status was successfully created.') }
        format.xml  { render :xml => @invoice_status, :status => :created, :location => @invoice_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoice_statuses/1
  # PUT /invoice_statuses/1.xml
  def update
    @invoice_status = InvoiceStatus.find(params[:id])

    respond_to do |format|
      if @invoice_status.update_attributes(params[:invoice_status])
        format.html { redirect_to(@invoice_status, :notice => 'Invoice status was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_statuses/1
  # DELETE /invoice_statuses/1.xml
  def destroy
    @invoice_status = InvoiceStatus.find(params[:id])
    @invoice_status.destroy

    respond_to do |format|
      format.html { redirect_to(invoice_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
