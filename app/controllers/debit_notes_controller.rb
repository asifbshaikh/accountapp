class DebitNotesController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /debit_notes
  # GET /debit_notes.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => DebitNotesDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def deleted_debit_note
    @search = @company.debit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @debit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @debit_notes }
    end
  end

  # GET /debit_notes/1
  # GET /debit_notes/1.xml
  def show
    @debit_note = @company.debit_notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @debit_note }
      format.pdf do 
        pdf = DebitNotePdf.new(view_context, @debit_note)
        send_data pdf.render, :filename=>"#{@debit_note.debit_note_number}.pdf", disposition: "inline", type: "application/pdf"
      end
    end
  end

  # GET /debit_notes/new
  # GET /debit_notes/new.xml
  def new
    @debit_note = DebitNote.new_note(@company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @debit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @debit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @debit_note }
    end
  end

  # GET /debit_notes/1/edit
  def edit
    @debit_note = @company.debit_notes.find(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @debit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @debit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  end

  # POST /debit_notes
  # POST /debit_notes.xml
  def create
    @debit_note = DebitNote.create_note(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @debit_note.valid?
        @debit_note.save_with_ledgers
        @debit_note.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(debit_notes_url, :notice => 'Debit note was successfully created.') }
        format.xml  { render :xml => @debit_note, :status => :created, :location => @debit_note }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @debit_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @debit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @debit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /debit_notes/1
  # PUT /debit_notes/1.xml
  def update
    @debit_note = DebitNote.update_note(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      @debit_note.update_attributes(params[:debit_note])
      if @debit_note.valid?
         @debit_note.update_and_post_ledgers
         @debit_note.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(debit_notes_url, :notice => 'Debit note was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @debit_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @debit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @debit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /debit_notes/1
  # DELETE /debit_notes/1.xml
  #soft delete debitnote
  def destroy
    @debit_note = @company.debit_notes.find(params[:id])
    @debit_note.fin_year = @financial_year.year.name
    respond_to do |format|
      if @debit_note.destroy
        @debit_note.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(debit_notes_url, :notice => "Debit note entry has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.debit_notes.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @debit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The debit note entry was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @debit_note.errors, :status => :unprocessable_entity }
      end
    end
  end
#restore debit note
  def restore_debit_note
    @debit_note = @company.debit_notes.find(params[:id])
    @debit_note.fin_year = @financial_year.year.name
    respond_to do |format|
      if @debit_note.restore(@current_user.id)
        @debit_note.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(debit_notes_url, :notice => "Debit note entry has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.debit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @debit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The debit note entry was not restored due to an error."
        format.html { render :action => "deleted_debit_note" }
        format.xml  { render :xml => @debit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete expense
  def permanent_delete_debit_note
    @debit_note = @company.debit_notes.find(params[:id])
    respond_to do |format|
	if @debit_note.destroy
      @debit_note.register_user_action(request.remote_ip, 'deleted')
	  format.html { redirect_to(debit_notes_deleted_debit_note_url, :notice => "Debit note has been permanently deleted") }
	  format.xml  { head :ok }
	else
  	@search = @company.debit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @debit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
    flash[:error] = "The debit note entry was not deleted due to an error."
    format.html { render :action => "deleted_debit_note" }
    format.xml  { render :xml => @debit_note.errors, :status => :unprocessable_entity }

      end
    end
  end
  def add_account
    @account_heads = nil
    @data_account = nil
    if params[:transaction_type] == 'journal'
	  @account_heads = AccountHead.get_journal_to_heads(@company.id)
	  @data_account = 'journal'
  	elsif params[:transaction_type] =='journal_to'
  	  @account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  	  @data_account = 'journal_to'
  	end
  end

  def allocate
    @debit_note=DebitNote.allocate_debit(params, @company)
  end

  def create_allocation
    @debit_note=DebitNote.create_allocation(params, @company)
    respond_to do |format|
      if @debit_note.save
        @debit_note.manage_purchase_and_debit_note_status
        format.html { redirect_to debit_note_path(@debit_note), :notice => 'Debit note was successfully updated.'}
      else
        format.html { render :action=>"allocate"}
      end
    end
  end

  def remove_allocation
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
end
