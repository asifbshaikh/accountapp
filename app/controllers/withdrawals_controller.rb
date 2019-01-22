class WithdrawalsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /withdrawals
  # GET /withdrawals.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => WithdrawalsDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_withdrawal
    @search = @company.withdrawals.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @withdrawals = @search.order("transaction_date DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @withdrawals }
    end
  end
  # GET /withdrawals/1
  # GET /withdrawals/1.xml
  def show
    @withdrawal = @company.withdrawals.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @withdrawal }
    end
  end

  # GET /withdrawals/new
  # GET /withdrawals/new.xml
  def new
    @withdrawal = Withdrawal.new_record(@company)
    @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
    @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
    @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

    @deposit = Deposit.new_deposit(@company)
    @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
    @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
    @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
    @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)

    @transfer_cash = TransferCash.new_transfer(@company)
    @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
    @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
    @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
    @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @withdrawal }
    end
  end

  # GET /withdrawals/1/edit
  def edit
    @withdrawal = @company.withdrawals.find(params[:id])
    @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
    @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
    @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
    @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

  end

  # POST /withdrawals
  # POST /withdrawals.xml
  def create
    @withdrawal = Withdrawal.create_record(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @withdrawal.valid?
         @withdrawal.save_with_ledgers
				#[OPTIMIZE] This code needs to be refactored.
         if !params[:transaction_id].blank? && !params[:account_id].blank?
         transaction = Ledger.where(:account_id => params[:account_id])
         bank_statement_line_item = BankStatementLineItem.find(params[:transaction_id])
         transaction.last.update_attributes(:reconcilation_status => true, :reconcilation_date => Time.zone.now.to_date)
         bank_statement_line_item.update_attributes(:status => 1, :ledger_id => transaction.last.id)
         end
         @withdrawal.register_user_action(request.remote_ip, 'created')
        format.js {render "bank_statements/create_payment"}
        format.html { redirect_to('/banking/index#withdraw', :notice => 'Withdrawal was successfully created.') }
        format.xml  { render :xml => @withdrawal, :status => :created, :location => @withdrawal }
      else
        @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
        @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
        @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
        @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        @deposit = Deposit.new_deposit(@company)
        @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
        @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
        @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
        @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)

        @transfer_cash = TransferCash.new_transfer(@company)
        @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
        @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
        @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
        @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        format.js {render "bank_statements/create_payment"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @withdrawal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /withdrawals/1
  # PUT /withdrawals/1.xml
   def update
    @withdrawal = Withdrawal.update_record(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      # @withdrawal.update_attributes(params[:withdrawal])
      if @withdrawal.valid?
        @withdrawal.update_and_post_ledgers
        @withdrawal.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to('/banking/index#withdraw', :notice => 'Withdrawal was successfully updated.') }
        format.xml  { head :ok }
      else
        @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
        @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
        @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
        @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @withdrawal.errors, :status => :unprocessable_entity }
      end
    end
  end

 #soft delete withdrawals

   def destroy
    @withdrawal = @company.withdrawals.find(params[:id])
    @withdrawal.fin_year = @financial_year.year.name
    respond_to do |format|
      if @withdrawal.destroy
         @withdrawal.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to('/banking/index#withdraw', :notice => "Withdrawal history is successfully deleted") }
        format.xml  { head :ok }
      else
       @search = @company.withdrawals.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
       @withdrawals = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The withdrawal history was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @withdrawal.errors, :status => :unprocessable_entity }
      end
    end
  end

 #restoring withdrawal
 def restore_withdrawal
     @withdrawal = @company.withdrawals.find(params[:id])
     @withdrawal.fin_year = @financial_year.year.name
    respond_to do |format|
      if @withdrawal.restore(@current_user.id)
         @withdrawal.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to('/banking/index#withdraw', :notice => "Withdrawal history is successfully restored") }
        format.xml  { head :ok }
      else
       @search = @company.withdrawals.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
       @withdrawals = @search.order("transaction_date DESC").page(params[:page]).per(20)
       flash[:error] = "The withdrawal history was not restored due to an error."
        format.html { render :action => "deleted_withdrawal" }
        format.xml  { render :xml => @withdrawal.errors, :status => :unprocessable_entity }
      end
    end
   end

  #Hard delete withdrawal

  def permanent_delete_withdrawal
    @withdrawal = @company.withdrawals.find(params[:id])
    respond_to do |format|
      if @withdrawal.destroy
         @withdrawal.register_user_action(request.remote_ip, 'deleted')
       	 format.html { redirect_to('/banking/index#withdraw', :notice => "Withdrawal has been permanently deleted") }
      	 format.xml  { head :ok }
      else
	      @search = @company.withdrawals.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @withdrawals = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The withdrawal was not deleted due to an error."
        format.html { render :action => "deleted_withdrawal" }
        format.xml  { render :xml => @withdrawal.errors, :status => :unprocessable_entity }
      end
   end
  end


 def add_account
    @data_account = nil
  if params[:transaction_type] == 'bankacc'
 	   @account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
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
