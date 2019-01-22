class DepositsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /deposits
  # GET /deposits.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => DepositsDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_deposit
    @search = @company.deposits.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @deposits = @search.order("transaction_date DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deposits }
    end
  end

  # GET /deposits/1
  # GET /deposits/1.xml
  def show
    @deposit = @company.deposits.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deposit }
    end
  end

  # GET /deposits/new
  # GET /deposits/new.xml
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
      format.xml  { render :xml => @deposit }
    end
  end

  # GET /deposits/1/edit
  def edit
    @deposit = @company.deposits.find(params[:id])
    @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
    @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
    @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
    @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)
  end

  # POST /deposits
  # POST /deposits.xml
  def create
    @deposit = Deposit.create_deposit(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @deposit.valid?
        @deposit.save_with_ledgers
        if !params[:transaction_id].blank? && !params[:account_id].blank?
         transaction = Ledger.where(:account_id => params[:account_id])
         bank_statement_line_item = BankStatementLineItem.find(params[:transaction_id])
         transaction.last.update_attributes(:reconcilation_status => true, :reconcilation_date => Time.zone.now.to_date)
         bank_statement_line_item.update_attributes(:status => 1, :ledger_id => transaction.last.id)
        end
        @deposit.register_user_action(request.remote_ip, "created")
        format.js {render "bank_statements/create_receipt"}
        format.html { redirect_to('/banking/index#deposit', :notice => 'Deposit was successfully created.') }
        format.xml  { render :xml => @deposit, :status => :created, :location => @deposit }
      else
        @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
        @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
        @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
        @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)

        @withdrawal = Withdrawal.new_record(@company)
        @with_from_accounts = TransactionType.fetch_from_accounts(@company.id,'bankacc')
        @with_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'cashacc')
        @with_from_account_heads = AccountHead.get_bank_and_loan_from_heads(@company.id)
        @with_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        @transfer_cash = TransferCash.new_transfer(@company)
        @tran_from_accounts = TransactionType.fetch_from_accounts(@company.id, 'transferacc')
        @tran_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'transferacc')
        @tran_from_account_heads = AccountHead.get_transferacc_from_heads(@company.id)
        @tran_to_account_heads = AccountHead.get_contra_to_heads(@company.id)

        format.js {render "bank_statements/create_receipt"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @deposit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deposits/1
  # PUT /deposits/1.xml
  def update
    @deposit = Deposit.update_deposit(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      # @deposit.update_attributes(params[:deposit])
      if @deposit.valid?
        @deposit.update_and_post_ledgers
        @deposit.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to('/banking/index#deposit', :notice => 'Deposit was successfully updated.') }
        format.xml  { head :ok }
      else
        @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
        @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
        @dep_from_account_heads = AccountHead.get_cashacc_from_heads(@company.id)
        @dep_to_account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deposit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @deposit = @company.deposits.find(params[:id])
    @deposit.fin_year = @financial_year.year.name
    respond_to do |format|
      if @deposit.destroy
        @deposit.register_delete_action(request.remote_ip, @current_user, 'deleted')
        format.html { redirect_to('/banking/index#deposit', :notice => "Deposit  history has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.deposits.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @deposits = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The deposit history was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @deposit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def restore_deposit
    @deposit = @company.deposits.find(params[:id])
    @deposit.fin_year = @financial_year.year.name
    respond_to do |format|
      if @deposit.restore(@current_user.id)
        @deposit.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to('/banking/index#deposit', :notice => "Deposit  history has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.deposits.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @deposits = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The deposit history was not restored due to an error."
        format.html { render :action => "deleted_deposit" }
        format.xml  { render :xml => @deposit.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete deposit
  def permanent_delete_deposit
    @deposit = @company.deposits.find(params[:id])
    respond_to do |format|
	if @deposit.destroy
    @deposit.register_user_action(request.remote_ip, 'deleted')
	  format.html { redirect_to('/banking/index#deposit', :notice => "Deposit entry has been permanently deleted") }
	  format.xml  { head :ok }
	else
	      @search = @company.deposits.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @deposits = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The deposit history was not deleted due to an error."
        format.html { render :action => "deleted_deposit" }
        format.xml  { render :xml => @deposit.errors, :status => :unprocessable_entity }

      end
    end
  end
 def add_account
    @data_account = nil
    if params[:transaction_type] == 'cashacc'
	  @account_heads = AccountHead.get_cashacc_from_heads(@company.id)
	  @data_account = 'from_account_auto_complete'
	else
          @account_heads = nil
	  @account_heads = AccountHead.get_bank_and_loan_to_heads(@company.id)
	  @data_account = 'to_account_auto_complete'
	end

  end
  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :controller => :banking ,:action=> :index
  end


end
