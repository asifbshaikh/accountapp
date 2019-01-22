class TransferCashesController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /transfer_moneys
  # GET /transfer_moneys.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => TransferCashesDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_transfer_history
    @search = @company.transfer_cashes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @transfer_cashes = @search.order("transaction_date DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transfer_cashes }
    end
  end
  # GET /transfer_moneys/1
  # GET /transfer_moneys/1.xml
  def show
    @transfer_cash = @company.transfer_cashes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transfer_cash }
    end
  end

  # GET /transfer_moneys/new
  # GET /transfer_moneys/new.xml
  def new
    @transfer_cash = TransferCash.new_transfer(@company)
    @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
    @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
    @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
    @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

    @withdrawal = Withdrawal.new_record(@company)
    @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
    @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    @with_from_account_heads = AccountHead.get_bankacc_from_heads(@company.id)
    @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

    @deposit = Deposit.new_deposit(@company)
    @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
    @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
    @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
    @dep_to_account_heads = AccountHead.get_bankacc_to_heads(@company.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transfer_cash }
    end
  end

  # GET /transfer_moneys/1/edit
  def edit
     @transfer_cash = @company.transfer_cashes.find(params[:id])
     @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
     @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
     @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
    @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
  end

  # POST /transfer_moneys
  # POST /transfer_moneys.xml
   def create
    @transfer_cash = TransferCash.create_transfer(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @transfer_cash.valid?
         @transfer_cash.save_with_ledgers
         @transfer_cash.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to('/banking/index#transfer-cash', :notice => 'Transfer cash was successfully created.') }
        format.xml  { render :xml => @transfer_cash, :status => :created, :location => @transfer_cash }
      else
        @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
        @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
        @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
        @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        @withdrawal = Withdrawal.new_record(@company)
        @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
        @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
        @with_from_account_heads = AccountHead.get_bankacc_from_heads(@company.id)
        @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        @deposit = Deposit.new_deposit(@company)
        @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
        @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
        @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
        @dep_to_account_heads = AccountHead.get_bankacc_to_heads(@company.id)

        format.html { render :action => "new" }
        format.xml  { render :xml => @transfer_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transfer_moneys/1
  # PUT /transfer_moneys/1.xml
  def update
    @transfer_cash = TransferCash.update_transfer(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      # @transfer_cash.update_attributes(params[:transfer_cash])
      if @transfer_cash.valid?
        @transfer_cash.update_and_post_ledgers
        @transfer_cash.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to('/banking/index#transfer-cash', :notice => 'Transfer cash was successfully updated.') }
        format.xml  { head :ok }
      else
        @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
        @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
        @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
        @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transfer_cash.errors, :status => :unprocessable_entity }
      end
    end
  end


   def destroy
    @transfer_cash = @company.transfer_cashes.find(params[:id])
    @transfer_cash.fin_year = @financial_year.year.name
    respond_to do |format|
      if @transfer_cash.destroy
        @transfer_cash.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to('/banking/index#transfer-cash', :notice => "Transfer history has been successfully deleted") }
        format.xml  { head :ok }
      else
       @search = @company.transfer_cashes.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
       @transfer_cashes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "Transfer history was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @transfer_cash.errors, :status => :unprocessable_entity }
      end
    end
  end


 def restore_transfer_history
     @transfer_cash = @company.transfer_cashes.find(params[:id])
     @transfer_cash.fin_year = @financial_year.year.name
    respond_to do |format|
      if @transfer_cash.restore(@current_user.id)
        @transfer_cash.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to('/banking/index#transfer-cash', :notice => "Transfer history has been successfully restored") }
        format.xml  { head :ok }
      else
       @search = @company.transfer_cashes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
       @transfer_cashes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The transfer history was not restored due to an error."
        format.html { render :action => "deleted_transfer_history" }
        format.xml  { render :xml => @transfer_cash.errors, :status => :unprocessable_entity }
      end
    end
   end


 #Hard delete transfer history
  def permanent_delete_transfer_history
    @transfer_cash = @company.transfer_cashes.find(params[:id])
    respond_to do |format|
      if @transfer_cash.destroy
        @transfer_cash.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to('/banking/index#transfer-cash', :notice => "Transfer history has been successfully deleted") }
        format.xml  { head :ok }
      else
       @search = @company.transfer_cashes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
       @transfer_cashes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The transfer history was not deleted due to an error."
        format.html { render :action => "deleted_transfer_history" }
        format.xml  { render :xml => @transfer_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

 def add_account
    @data_account = nil
    if params[:transaction_type] == 'transferacc'
	  @account_heads = AccountHead.get_transferacc_from_heads(@company.id)
	  @data_account = 'from_account_auto_complete'
	else
	  @account_heads = AccountHead.get_contra_to_heads(@company.id)
	  @data_account = 'to_account_auto_complete'
	end

  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :controller => :banking ,:action=> :index
  end

end
