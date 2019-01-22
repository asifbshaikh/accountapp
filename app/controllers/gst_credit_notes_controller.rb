class GstCreditNotesController < ApplicationController
  # GET /gst_credit_notes
  # GET /gst_credit_notes.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => GstCreditNotesDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  # GET /gst_credit_notes/1
  # GET /gst_credit_notes/1.json
  def show
    #@gst_credit_note = GstCreditNote.find(params[:id])
    @gst_credit_note = @company.gst_credit_notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gst_credit_note }
      format.pdf do 
        pdf = GstCreditNotePdf.new(view_context, @gst_credit_note, @company)
        send_data pdf.render, :filename=>"#{@gst_credit_note.gst_credit_note_number}.pdf", disposition: "inline", type: "application/pdf"
      end
    end
  end

  # GET /gst_credit_notes/new
  # GET /gst_credit_notes/new.json
  def new
    @gst_credit_note = GstCreditNote.new_note(@company)
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @gst_credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @gst_credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gst_credit_note }
    end
  end

  # GET /gst_credit_notes/1/edit
  def edit
    #@gst_credit_note = GstCreditNote.find(params[:id])
    @gst_credit_note = @company.gst_credit_notes.find(params[:id])
    @from_accounts = TransactionType.fetch_from_accounts(@company.id, 'journal')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @gst_credit_account_heads = AccountHead.get_journal_to_heads(@company.id)
    @gst_credit_to_account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
  end

  # POST /gst_credit_notes
  # POST /gst_credit_notes.json
  def create
    #@gst_credit_note = GstCreditNote.new(params[:gst_credit_note])

    respond_to do |format|
      if @gst_credit_note.save
        format.html { redirect_to @gst_credit_note, notice: 'Gst credit note was successfully created.' }
        format.json { render json: @gst_credit_note, status: :created, location: @gst_credit_note }
      else
        format.html { render action: "new" }
        format.json { render json: @gst_credit_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gst_credit_notes/1
  # PUT /gst_credit_notes/1.json
  def update
    @gst_credit_note = GstCreditNote.find(params[:id])

    respond_to do |format|
      if @gst_credit_note.update_attributes(params[:gst_credit_note])
        format.html { redirect_to @gst_credit_note, notice: 'Gst credit note was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gst_credit_note.errors, status: :unprocessable_entity }
      end
    end
  end

    def allocate
     @gst_credit_note= @company.gst_credit_notes.find(params[:id])
    end

     def create_allocation
    @gst_credit_note=GstCreditNote.create_allocation(params, @company)
    respond_to do |format|
      if @gst_credit_note.save
        @gst_credit_note.manage_invoice_status
        @gst_credit_note.manage_gst_credit_note_status
        format.html { redirect_to gst_credit_note_path(@gst_credit_note), :notice => 'GST Credit note was successfully updated.'}
      else
        format.html { render :action=>"allocate"}
      end
    end
  end

  def remove_allocation
  end
    # def allocate
    #   @gst_credit_note = GstCreditNote.find(params[:id])

    #   respond_to do |format|
    #     format.html
    #     format.json { render json: @gst_credit_note }
    #   end
    # end

  # DELETE /gst_credit_notes/1
  # DELETE /gst_credit_notes/1.json
  def destroy
    @gst_credit_note = GstCreditNote.find(params[:id])
    @gst_credit_note.delete_gstr_one_entry
    @gst_credit_note.destroy

    respond_to do |format|
      format.html { redirect_to gst_credit_notes_url }
      format.json { head :ok }
    end
  end
end
