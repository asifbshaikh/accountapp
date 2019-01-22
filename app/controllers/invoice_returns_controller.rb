class InvoiceReturnsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /invoice_returns
  # GET /invoice_returns.json
  def index
    # @invoice_returns = InvoiceReturn.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => InvoiceReturnDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /invoice_returns/1
  # GET /invoice_returns/1.json
  def show
    @invoice_return = InvoiceReturn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @invoice_return }
      format.pdf do
        pdf=InvoiceReturnPdf.new(@invoice_return)
        send_data pdf.render, :filename=>"#{@invoice_return.invoice_return_number}.pdf", :disposition=>'inline', :type=>"application/pdf"
      end
    end
  end

  # GET /invoice_returns/new
  # GET /invoice_returns/new.json
  def new
    @invoice_return = InvoiceReturn.new_invoice_return(params, @company)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @invoice_return }
    end
  end

  # GET /invoice_returns/1/edit
  def edit
    @invoice_return = InvoiceReturn.find(params[:id])
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
  end

  # POST /invoice_returns
  # POST /invoice_returns.json
  def create
    @invoice_return = InvoiceReturn.create_invoice_return(params, @company, @current_user.id)
    invoice_status = @invoice_return.invoice.invoice_status_id

    respond_to do |format|
      if @invoice_return.save_and_manage_credit_note(request.remote_ip)
        format.html { redirect_to @invoice_return, :notice => 'Invoice return was successfully created.' }
        format.json { render :json => @invoice_return, :status => :created, :location => @invoice_return }
      else
        format.html { render :action => "new" }
        format.json { render :json => @invoice_return.errors, :status => :unprocessable_entity }
      end
      logger.debug "inv ret #{@invoice_return.inspect}"
      if @invoice_return.invoice.gst_invoice? && invoice_status !=0
        GstCreditNoteWorker.perform(@invoice_return, request.remote_ip, @company.id)
        flash[:success] = "GST credit note  was successfully created."
      end
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    end
  end

  # PUT /invoice_returns/1
  # PUT /invoice_returns/1.json
  def update
    @invoice_return = InvoiceReturn.update_invoice_return(params, @company)

    respond_to do |format|
      if @invoice_return.valid?
        @invoice_return.update_and_manage_credit_note(request.remote_ip)
        if @invoice_return.gst_credit_note.present?
          GstCreditNoteWorker.update_gst_credit_note(@invoice_return, params, request.remote_ip, @company)
          flash[:success] = "GST credit note  was successfully updated."
        end
        format.html { redirect_to @invoice_return, :notice => 'Invoice return was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @invoice_return.errors, :status => :unprocessable_entity }
      end
      @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    end
  end

  # DELETE /invoice_returns/1
  # DELETE /invoice_returns/1.json
  def destroy
    @invoice_return = InvoiceReturn.find(params[:id])
    @invoice_return.destroy

    respond_to do |format|
      format.html { redirect_to invoices_url(:anchor=>"return-invoices-tab"), :notice => "Invoice return was deleted successfully." }
      format.json { head :ok }
    end
  end

  def remove_line_item
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :controller=>:invoices, :action=> :index, :anchor=>"return-invoices-tab"
  end
end
