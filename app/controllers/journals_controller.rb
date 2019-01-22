class JournalsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /journals
  # GET /journals.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => JournalsDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_journal
    @search = @company.journals.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @journals = @search.order(:date).page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @journals }
    end
  end

  # GET /journals/1
  # GET /journals/1.xml
  def show
    @journal = @company.journals.find(params[:id])
    @journal_line_items = @journal.journal_line_items
    respond_to do |format|
      format.html # show.html.erb
      format.pdf { render :layout => false}
      format.xml  { render :xml => @journal }
      prawnto :filename => "#{@journal.voucher_number}.pdf"
    end
  end

  # GET /journals/new
  # GET /journals/new.xml
  def new
    if !params[:journal_id].blank?
      @journal_import_id = params[:journal_id]
      @journal = Journal.correct_journal(@journal_import_id,@company,@current_user)
      @journal.valid?
    else
      @journal = Journal.new_journal(params, @company)
    end
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
    @journal_to_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @journal_from_account_heads = AccountHead.get_journal_from_heads(@company.id)
    @projects = @company.projects.active
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @journal }
    end
  end

  # GET /journals/1/edit
  def edit
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'saccounting')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
    @journal = @company.journals.find(params[:id])
    @journal_to_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @journal_from_account_heads = AccountHead.get_journal_from_heads(@company.id)
    @projects = @company.projects.active
  end

  # POST /journals
  # POST /journals.xml
  def create
    @journal = Journal.create_journal(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @journal.valid?
        VoucherSetting.next_journal_write(@company)
        @journal.save_with_ledgers
        @journal.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(@journal, :notice => 'Journal was successfully created.') }
        format.xml  { render :xml => @journal, :status => :created, :location => @journal }
      else  
        @journal.voucher_number = VoucherSetting.next_journal_number(@company)
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
        @journal_to_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @journal_from_account_heads = AccountHead.get_journal_from_heads(@company.id)
        @projects = @company.projects.active
        format.html { render :action => "new" }
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /journals/1
  # PUT /journals/1.xml
  def update
    @journal = Journal.update_journal(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      @journal.update_attributes(params[:journal])
      if @journal.valid?
        @journal.update_and_post_ledgers
        @journal.update_attribute("total_amount", @journal.amount)
        @journal.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@journal, :notice => 'Journal was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'saccounting')
        @journal_to_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @journal_from_account_heads = AccountHead.get_journal_from_heads(@company.id)
        @projects = @company.projects.active
        format.html { render :action => "edit" }
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.xml
 #soft delete journal
  def soft_delete
    @journal = @company.journals.find(params[:id])
    @journal.fin_year = @financial_year.year.name
    respond_to do |format|
      if @journal.delete(@current_user.id)
        @journal.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(journals_url, :notice => "Journal entry has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.journals.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @journals = @search.order(:date).page(params[:page]).per(20)
        flash[:error] = "The journal entry was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end
#restore journal
  def restore_journal
    @journal = @company.journals.find(params[:id])
    @journal.fin_year = @financial_year.year.name
    respond_to do |format|
      if @journal.restore(@current_user.id)
        @journal.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(journals_url, :notice => "Journal entry has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.journals.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @journals = @search.order(:date).page(params[:page]).per(20)
        flash[:error] = "The journal entry was not restored due to an error."
        format.html { render :action => "deleted_journal" }
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete expense
  def destroy
    @journal = @company.journals.find(params[:id])
    respond_to do |format|
	if @journal.destroy
    @journal.register_delete_action(request.remote_ip, @current_user, 'deleted')
	  format.html { redirect_to(journals_url, :notice => "Journal has been permanently deleted") }
	  format.xml  { head :ok }
	else
	  # @search = @company.journals.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
   #  @journals = @search.order(:date).page(params[:page]).per(20)
    flash[:error] = "The journal entry was not deleted due to an error."
    format.html { render :action => "index" }
    format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
    end
    end
  end


  # add_row /add_row ajax call
  def add_row
    @journal = Journal.new_journal(params, @company)
    @journal_line_item = JournalLineItem.new
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'saccounting')
    respond_to do |format|
      format.js
    end
  end

  def add_account
    @account_heads = nil
    @data_account = nil
   if params[:transaction_type] == 'journal'
  	  @account_heads = AccountHead.get_journal_to_heads(@company.id)
  	  @data_account = 'journal'
   elsif params[:transaction_type] =='journal_from'
  	  @account_heads = AccountHead.get_journal_from_heads(@company.id)
  	  @data_account = 'journal_from'
  	end
  end
  private
  
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
end
