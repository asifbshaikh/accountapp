class SaccountingsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /saccountings
  # GET /saccountings.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => SaccountingsDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end
  def deleted_saccounting
    @search = @company.saccountings.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @saccountings = @search.order("voucher_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @saccountings }
    end
  end

  # GET /saccountings/1
  # GET /saccountings/1.xml
  def show
    @saccounting = @company.saccountings.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf { render :layout => false}
      format.xml  { render :xml => @saccounting }
      prawnto :filename => "#{@saccounting.voucher_number}.pdf"
    end
  end

  # GET /saccountings/new
  # GET /saccountings/new.xml
  def new
    @saccounting = Saccounting.new_saccounting(@company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
    @saccounting_to_account_heads = AccountHead.get_saccounting_to_heads(@company.id)
    @saccounting_from_account_heads = AccountHead.get_saccounting_from_heads(@company.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @saccounting }
    end
  end

  # GET /saccountings/1/edit
  def edit
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'saccounting')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
    @saccounting = @company.saccountings.find(params[:id])
    @saccounting_to_account_heads = AccountHead.get_saccounting_to_heads(@company.id)
    @saccounting_from_account_heads = AccountHead.get_saccounting_from_heads(@company.id)
  end

  # POST /saccountings
  # POST /saccountings.xml
  def create
    @saccounting = Saccounting.create_saccounting(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @saccounting.valid?
        @saccounting.save_with_ledgers
        @saccounting.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@saccounting, :notice => 'Saccounting successfully created.') }
        format.xml  { render :xml => @saccounting, :status => :created, :location => @saccounting }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
        @saccounting_to_account_heads = AccountHead.get_saccounting_to_heads(@company.id)
        @saccounting_from_account_heads = AccountHead.get_saccounting_from_heads(@company.id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @saccounting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /saccountings/1
  # PUT /saccountings/1.xml
  def update
    @saccounting = Saccounting.update_saccounting(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      @saccounting.update_attributes(params[:saccounting])
      if @saccounting.valid?
        @saccounting.update_and_post_ledgers
        @saccounting.update_attribute("total_amount", @saccounting.amount)
        @saccounting.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@saccounting, :notice => 'Saccounting was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
        @saccounting_to_account_heads = AccountHead.get_saccounting_to_heads(@company.id)
        @saccounting_from_account_heads = AccountHead.get_saccounting_from_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @saccounting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /saccountings/1
  # DELETE /saccountings/1.xml
  #soft delete saccounting
  def destroy
    @saccounting = @company.saccountings.find(params[:id])
    @saccounting.fin_year = @financial_year.year.name
    respond_to do |format|
      if @saccounting.destroy
        @saccounting.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to(saccountings_url, :notice => "Simple accounting entry has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.saccountings.by_branch_id(@current_user.branch_id).by_delete(false).by_date(@financial_year).search(params[:search])
        @saccountings = @search.order("voucher_date DESC").page(params[:page]).per(20)

        flash[:error] = "The simple accounting entry was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @saccounting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_row
    @saccounting_line_item = SaccountingLineItem.new
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
    respond_to do |format|
      format.js
    end
  end

  def remove_line_item
   #just need to initiate ajax call
  end

  def add_account
    @account_heads = nil
    @data_account = nil
    if params[:transaction_type] == 'saccounting'
	    @account_heads = AccountHead.get_saccounting_from_heads(@company.id)
	    @data_account = 'journal_from'
  	elsif params[:transaction_type] =='saccounting_to'
  	  @account_heads = AccountHead.get_saccounting_to_heads(@company.id)
  	  @data_account = 'journal'
  	end
  end

  private

  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
