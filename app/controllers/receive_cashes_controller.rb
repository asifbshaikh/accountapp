class ReceiveCashesController < ApplicationController
  layout "application", :except => [:show]
  # GET /receive_moneys
  # GET /receive_moneys.xml
  def index
    @receive_cashes = ReceiveCash.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @receive_cashes }
    end
  end

  # GET /receive_moneys/1
  # GET /receive_moneys/1.xml
  def show
    @receive_cash = ReceiveCash.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @receive_cash }
    end
  end

  # GET /receive_moneys/new
  # GET /receive_moneys/new.xml
  def new
    @receive_cash = ReceiveCash.new
    
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @receive_cash }
    end
  end

  # GET /receive_moneys/1/edit
  def edit
    @receive_cash = ReceiveCash.find(params[:id])
  end

  # POST /receive_moneys
  # POST /receive_moneys.xml
  def create
    @receive_cash = ReceiveCash.new(params[:receive_cash])
    @receive_cash.company_id = @company.id
    @receive_cash.created_by = session[:current_user_id]
    respond_to do |format|
      if @receive_cash.save_with_ledgers
        format.html { redirect_to(@receive_cash, :notice => 'Receive money was successfully created.') }
        format.xml  { render :xml => @receive_cash, :status => :created, :location => @receive_cash }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @receive_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /receive_moneys/1
  # PUT /receive_moneys/1.xml
  def update
    @receive_cash = ReceiveCash.find(params[:id])

    respond_to do |format|
      if @receive_cash.update_attributes(params[:receive_cash])
        format.html { redirect_to(@receive_cash, :notice => 'Receive cash was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @receive_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /receive_moneys/1
  # DELETE /receive_moneys/1.xml
  def destroy
    @receive_cash = ReceiveCash.find(params[:id])
    @receive_cash.destroy

    respond_to do |format|
      format.html { redirect_to(receive_cash_url) }
      format.xml  { head :ok }
    end
  end
end
