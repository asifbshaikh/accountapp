class GstDebitNotesController < ApplicationController
  # GET /gst_debit_notes
  # GET /gst_debit_notes.json
  skip_before_filter :authorize_action
  def index
    #@gst_debit_notes = GstDebitNote.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: GstDebitNoteDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /gst_debit_notes/1
  # GET /gst_debit_notes/1.json
  def show
    @gst_debit_note = GstDebitNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=GstDebitNotePdf.new(@gst_debit_note)
        send_data pdf.render, :filename=>"#{@gst_debit_note.gst_debit_note_number}.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
      format.xml  { render :xml => @gst_debit_note }
      #format.json { render json: @gst_debit_note }
    end
  end

  # GET /gst_debit_notes/new
  # GET /gst_debit_notes/new.json
  def new
    @gst_debit_note = GstDebitNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gst_debit_note }
    end
  end

  # GET /gst_debit_notes/1/edit
  def edit
    @gst_debit_note = GstDebitNote.find(params[:id])
  end

  # POST /gst_debit_notes
  # POST /gst_debit_notes.json
  def create
    @gst_debit_note = GstDebitNote.new(params[:gst_debit_note])

    respond_to do |format|
      if @gst_debit_note.save
        format.html { redirect_to @gst_debit_note, notice: 'Gst debit note was successfully created.' }
        format.json { render json: @gst_debit_note, status: :created, location: @gst_debit_note }
      else
        format.html { render action: "new" }
        format.json { render json: @gst_debit_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gst_debit_notes/1
  # PUT /gst_debit_notes/1.json
  def update
    @gst_debit_note = GstDebitNote.find(params[:id])

    respond_to do |format|
      if @gst_debit_note.update_attributes(params[:gst_debit_note])
        format.html { redirect_to @gst_debit_note, notice: 'Gst debit note was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gst_debit_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gst_debit_notes/1
  # DELETE /gst_debit_notes/1.json
  def destroy
    @gst_debit_note = GstDebitNote.find(params[:id])
    @gst_debit_note.delete_gstr_two_entry
    @gst_debit_note.destroy

    respond_to do |format|
      format.html { redirect_to gst_debit_notes_url }
      format.json { head :ok }
    end
  end

  def allocate
    @gst_debit_note = @company.gst_debit_notes.find(params[:id])
  end

  def create_allocation
    @gst_debit_note=GstDebitNote.create_allocation(params, @company)
    logger.debug "gst_debit_note values #{@gst_debit_note.inspect}"
    respond_to do |format|
      if @gst_debit_note.save
        @gst_debit_note.manage_purchase_and_gst_debit_note_status
        @gst_debit_note.manage_gst_debit_note_status
        format.html { redirect_to gst_debit_note_path(@gst_debit_note), :notice => 'Gst Debit note was successfully updated.'}
      else
        format.html { render :action=>"allocate"}
      end
    end
  end

  def remove_allocation
  end

end
