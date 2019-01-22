class MakePaymentsController < ApplicationController
  
#   layout "application", :except => [:show]

  # GET /make_payments
  # GET /make_payments.xml
  def index
    @menu = 'Expenses'
    @page_name = 'Make Payment'
    @make_payments = MakePayment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @make_payments }
    end
  end

  # GET /make_payments/1
  # GET /make_payments/1.xml
  def show
    @menu = 'Expenses'
    @page_name = 'View Payment'
    @make_payment = MakePayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @make_payment }
    end
  end

  # GET /make_payments/new
  # GET /make_payments/new.xml
  def new
    @make_payment = MakePayment.new
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'payments')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'payments')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @make_payment }
    end
  end

  # GET /make_payments/1/edit
  def edit
    @make_payment = MakePayment.find(params[:id])
  end

  # POST /make_payments
  # POST /make_payments.xml
  def create
    @make_payment = MakePayment.new(params[:make_payment])
    #@make_payment.company_id = Company.find_by_subdomain(request.subdomain).id
    @make_payment.company_id = @company.id
    @make_payment.user_id = session[:current_user_id]
    respond_to do |format|
      if @make_payment.save
        format.html { redirect_to(@make_payment, :notice => 'Make payment was successfully created.') }
        format.xml  { render :xml => @make_payment, :status => :created, :location => @make_payment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @make_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /make_payments/1
  # PUT /make_payments/1.xml
  def update
    @make_payment = MakePayment.find(params[:id])

    respond_to do |format|
      if @make_payment.update_attributes(params[:make_payment])
        format.html { redirect_to(@make_payment, :notice => 'Make payment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @make_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /make_payments/1
  # DELETE /make_payments/1.xml
  def destroy
    @make_payment = MakePayment.find(params[:id])
    @make_payment.destroy

    respond_to do |format|
      format.html { redirect_to(make_payments_url) }
      format.xml  { head :ok }
    end
  end
end
