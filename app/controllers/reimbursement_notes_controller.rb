class ReimbursementNotesController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ReimbursementNotesDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  def show
    @reimbursement_note = @company.reimbursement_notes.find(params[:id])
    # @expense = @company.expenses.find(@reimbursement_note.expense_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reimbursement_note }
      format.pdf do
        pdf = ReimbursementNotePdf.new(view_context, @reimbursement_note)
        send_data pdf.render, :filename=>"Reimbursement Voucher - #{@reimbursement_note.reimbursement_note_number}.pdf", disposition: "inline", type: "application/pdf"
      end
    end
  end

  def new
    @reimbursement_note = ReimbursementNote.new_note(@company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
    # @expenses = @company.expenses
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    @reimbursement_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @reimbursement_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reimbursement_note }
    end
  end

  def edit
    @reimbursement_note = @company.reimbursement_notes.find(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
    # @expenses = @company.expenses
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    @reimbursement_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @reimbursement_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  end

  def create
    @reimbursement_note = ReimbursementNote.new(params[:reimbursement_note])
    @reimbursement_note_srvc = ReimbursementNoteService.new
    respond_to do |format|
      if @reimbursement_note_srvc.post_new_note(@company, @current_user, @financial_year.year.name, request.remote_ip, @reimbursement_note)
        format.html { redirect_to(@reimbursement_note, :notice => 'Reimbursement note was successfully created.') }
        format.xml  { render :xml => @reimbursement_note, :status => :created, :location => @reimbursement_note }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
        # @expenses = @company.expenses
        @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
        @reimbursement_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @reimbursement_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @reimbursement_note.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @reimbursement_note = ReimbursementNote.update_note(params, @company, @current_user, @fyr)
    @reimbursement_note_srvc = ReimbursementNoteService.new
    respond_to do |format|
      if @reimbursement_note_srvc.update_note(@company, @current_user, @financial_year.year.name, request.remote_ip, @reimbursement_note, params)
        format.html { redirect_to(reimbursement_notes_url, :notice => 'Reimbursement note was successfully updated.') }
        format.xml  { head :ok }
      else
        @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
        @reimbursement_account_heads = AccountHead.get_journal_to_heads(@company.id)
        @reimbursement_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
        format.html { render :action => "edit"}
        format.xml  { render :xml => @reimbursement_note.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  #soft delete Reimbursement Note
  def destroy
    @reimbursement_note_srvc = ReimbursementNoteService.new
    respond_to do |format|
      if @reimbursement_note_srvc.delete_note(@company, @current_user, request.remote_ip, params[:id])
        format.html { redirect_to(reimbursement_notes_url, :notice => "Reimbursement note entry has been successfully deleted") }
        format.xml  { head :ok }
      else
        flash[:error] = "The reimbursement note entry was not deleted due to an error."
        format.html { render :action => "index" }
        format.xml  { render :xml => @reimbursement_note.errors, :status => :unprocessable_entity }
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

  # add_row /add_row ajax call
  def add_row
    @reimbursement_note = ReimbursementNote.new_note(@company)
    #@reimbursement_note_line_item = ReimbursementNoteLineItem.new
    @reimbursement_note_line_item = @reimbursement_note.reimbursement_note_line_items.build
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'earningacc')
    @expense_account_heads = AccountHead.get_expense_acc_to_heads(@company.id)
    respond_to do |format|
      format.js
    end
  end

  def remove_line_item

  end

  # Email the reimbursement voucher to customer
  def email_reimbursement_note
    @reimbursement_note = @company.reimbursement_notes.find(params[:id])
    @reimbursement_note_srvc = ReimbursementNoteService.new
    pdf = ReimbursementNotePdf.new(view_context, @reimbursement_note)
    mail_to = params[:email]
    mail_to = mail_to.gsub(/\s+/, " ").strip
    subject = params[:subject]
    cc = params[:cc]
    cc = cc.gsub(/\s+/, " ").strip
    text = params[:text]
    @email_valid = validate_email?(mail_to+','+cc)
    if @email_valid
      Email.send_reimbursement_note(pdf.render, @reimbursement_note, @company, @current_user, subject, text, mail_to, cc).deliver
    else
      flash[:error]='Email is either blank or invalid. If you have entered multiple emails please separate them with commas'
    end
  end


  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end
end
