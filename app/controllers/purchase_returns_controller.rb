class PurchaseReturnsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /purchase_returns
  # GET /purchase_returns.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => PurchaseReturnDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /purchase_returns/1
  # GET /purchase_returns/1.json
  def show
    @purchase_return = PurchaseReturn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=PurchaseReturnPdf.new(@purchase_return)
        send_data pdf.render, :filename=>"#{@purchase_return.purchase_return_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.json { render :json => @purchase_return }
    end
  end

  # GET /purchase_returns/new
  # GET /purchase_returns/new.json
  def new
    @purchase_return = PurchaseReturn.new_purchase_return(params, @company)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @purchase_return }
    end
  end

  # GET /purchase_returns/1/edit
  def edit
    @purchase_return = PurchaseReturn.find(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
  end

  # POST /purchase_returns
  # POST /purchase_returns.json
  def create
    @purchase_return = PurchaseReturn.create_purchase_return(params, @company, @current_user.id)
    purchase_status = @purchase_return.purchase.status_id
     @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')
    respond_to do |format|
      if @purchase_return.save_and_update_total_amount(request.remote_ip)
        if @purchase_return.purchase.gst_purchase? && purchase_status != 0
          GstDebitNoteWorker.perform(@purchase_return,request.remote_ip, @company.id)
        end
        format.html { redirect_to @purchase_return, :notice => 'Purchase return was successfully created.' }
        format.json { render :json => @purchase_return, :status => :created, :location => @purchase_return }
      else
        #@from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        format.html { render :action => "new" }
        format.json { render :json => @purchase_return.errors, :status => :unprocessable_entity }
      end
     
    end
  end

  # PUT /purchase_returns/1
  # PUT /purchase_returns/1.json
  def update
    @purchase_return = PurchaseReturn.update_purchase_return(params, @company)
    @tax_accounts = TransactionType.fetch_from_accounts(@company.id, 'tax')

    respond_to do |format|
      if @purchase_return.valid?
        @purchase_return.update_and_create_debit_note(request.remote_ip)
        if @purchase_return.purchase.gst_purchase?
          logger.debug "purchase_return #{@purchase_return.inspect}"
          GstDebitNoteWorker.update_gst_debit_note(@purchase_return,request.remote_ip)
        end
        format.html { redirect_to @purchase_return, :notice => 'Purchase return was successfully updated.' }
        format.json { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        format.html { render :action => "edit" }
        format.json { render :json => @purchase_return.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_returns/1
  # DELETE /purchase_returns/1.json
  def destroy
    @purchase_return = PurchaseReturn.find(params[:id])
    @purchase_return.destroy

    respond_to do |format|
      format.html { redirect_to purchases_url(:anchor=>"return-purchases-tab"), :notice=>"Purchase return was deleted successfully." }
      format.json { head :ok }
    end
  end

  def remove_line_item
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :controller=>:purchases, :action=> :index, :anchor=>"return-purchases-tab"
  end
end
