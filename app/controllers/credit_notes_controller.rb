class CreditNotesController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # before_filter :menu_title
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => CreditNotesDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

    def deleted_credit_note
    @search = @company.credit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @credit_notes = @search.order("transaction_date DESC").view_context, page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credit_notes }
    end
  end

  # GET /credit_notes/1
  # GET /credit_notes/1.xml
  def show
    @credit_note = @company.credit_notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit_note }
      format.pdf do 
        pdf = CreditNotePdf.new(view_context, @credit_note)
        send_data pdf.render, :filename=>"#{@credit_note.credit_note_number}.pdf", disposition: "inline", type: "application/pdf"
      end
    end
  end

  # GET /credit_notes/new
  # GET /credit_notes/new.xml
  def new
    @credit_note = CreditNote.new_note(@company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit_note }
    end
  end

  # GET /credit_notes/1/edit
  def edit
    @credit_note = @company.credit_notes.find(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  end

  # POST /credit_notes
  # POST /credit_notes.xml
  def create
    @credit_note = CreditNote.create_note(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      if @credit_note.valid?
         @credit_note.save_with_ledgers
         @credit_note.register_user_action(request.remote_ip, 'created')
        format.html { redirect_to(credit_notes_url, :notice => 'Credit note was successfully created.') }
        format.xml  { render :xml => @credit_note, :status => :created, :location => @credit_note }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @credit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credit_notes/1
  # PUT /credit_notes/1.xml
  def update
    @credit_note = CreditNote.update_note(params, @company.id, @current_user, @financial_year.year.name)
    respond_to do |format|
      @credit_note.update_attributes(params[:credit_note])
      if @credit_note.valid?
        @credit_note.update_and_post_ledgers
        @credit_note.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(credit_notes_url, :notice => 'Credit note was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @credit_note.fin_year = @financial_year.year.name
        @credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_notes/1
  # DELETE /credit_notes/1.xml
  #soft delete creditnote
  def destroy
    @credit_note = @company.credit_notes.find(params[:id])
    @credit_note.fin_year = @financial_year.year.name
    respond_to do |format|
      if @credit_note.destroy
        @credit_note.register_user_action(request.remote_ip, 'deleted')
        format.html { redirect_to(credit_notes_url, :notice => "credit note entry has been successfully deleted") }
        format.xml  { head :ok }
      else
        @search = @company.credit_notes.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(@financial_year).search(params[:search])
        @credit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The credit note entry was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @credit_note.errors, :status => :unprocessable_entity }
      end
    end
  end
#restore credit note
  def restore_credit_note
    @credit_note = @company.credit_notes.find(params[:id])
    @credit_note.fin_year = @financial_year.year.name
    respond_to do |format|
      if @credit_note.restore(@current_user.id)
        @credit_note.register_user_action(request.remote_ip, 'restored')
        format.html { redirect_to(credit_notes_url, :notice => "Credit note entry has been successfully restored") }
        format.xml  { head :ok }
      else
        @search = @company.credit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
        @credit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
        flash[:error] = "The credit note entry was not restored due to an error."
        format.html { render :action => "deleted_credit_note" }
        format.xml  { render :xml => @credit_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Hard delete expense
  def permanent_delete_credit_note
    @credit_note = @company.credit_notes.find(params[:id])
    respond_to do |format|
	if @credit_note.destroy
    @credit_note.register_user_action(request.remote_ip, 'deleted')
	  format.html { redirect_to(credit_notes_deleted_credit_note_url, :notice => "Credit note has been permanently deleted") }
	  format.xml  { head :ok }
	else
  	@search = @company.credit_notes.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @credit_notes = @search.order("transaction_date DESC").page(params[:page]).per(20)
    flash[:error] = "The credit note entry was not deleted due to an error."
    format.html { render :action => "deleted_credit_note" }
    format.xml  { render :xml => @credit_note.errors, :status => :unprocessable_entity }

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
    @credit_note=CreditNote.allocate_credit(params, @company)
  end

  def create_allocation
    @credit_note=CreditNote.create_allocation(params, @company)
    respond_to do |format|
      if @credit_note.save
        @credit_note.manage_invoice_and_credit_note_status
        format.html { redirect_to credit_note_path(@credit_note), :notice => 'Credit note was successfully updated.'}
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
