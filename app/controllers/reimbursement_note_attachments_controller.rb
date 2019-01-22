class ReimbursementNoteAttachmentsController < ApplicationController
  # skip_before_filter :authorize_action
  # GET /reimbursement_note_attachments
  # GET /reimbursement_note_attachments.json
  def index
    @reimbursement_note_attachments = ReimbursementNoteAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reimbursement_note_attachments }
    end
  end

  # GET /reimbursement_note_attachments/1
  # GET /reimbursement_note_attachments/1.json
  def show
   @reimbursement_note_attachment = ReimbursementNoteAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reimbursement_note_attachment }
    end
  end

  # GET /reimbursement_note_attachments/new
  # GET /reimbursement_note_attachments/new.json
  def new
     @reimbursement_note_attachments = ReimbursementNoteAttachment.reimbursement_note_attachments(params, @company, @current_user)
      subscription = Subscription.find_by_company_id(@company.id)
      if @reimbursement_note_attachments.save
        redirect_to :back,:notice => 'Attachment successfully Added.'
        elsif subscription.utilized_storage_mb.to_i >= subscription.allocated_storage_mb.to_i
            flash[:error] = "Storage limit reached, your plan does not allow storing any more files."
            redirect_to :back, :reimbursement_note_attachments => @reimbursement_note_attachments

      else
            flash[:error] = "Uploaded file must be pdf or image and file size between 0 and 5242880 bytes"
          redirect_to :back, :reimbursement_note_attachments => @reimbursement_note_attachments
      end
  end

  # GET /reimbursement_note_attachments/1/edit
  def edit
    @reimbursement_note_attachment = ReimbursementNoteAttachment.find(params[:id])
  end

  # POST /reimbursement_note_attachments
  # POST /reimbursement_note_attachments.json
  def create
    @reimbursement_note_attachment = ReimbursementNoteAttachment.new(params[:reimbursement_note_attachment])

    respond_to do |format|
      if @reimbursement_note_attachment.save
        format.html { redirect_to @reimbursement_note_attachment, notice: 'Reimbursement Note attachment was successfully created.' }
        format.json { render json: @reimbursement_note_attachment, status: :created, location: @reimbursement_note_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @reimbursement_note_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reimbursement_note_attachments/1
  # PUT /reimbursement_note_attachments/1.json
  def update
    @reimbursement_note_attachment = ReimbursementNoteAttachment.find(params[:id])

    respond_to do |format|
      if @reimbursement_note_attachment.update_attributes(params[:reimbursement_note_attachment])
        format.html { redirect_to @reimbursement_note_attachment, notice: 'Reimbursement Note attachment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @reimbursement_note_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reimbursement_note_attachments/1
  # DELETE /reimbursement_note_attachments/1.json
  def destroy
    @reimbursement_note_attachment = ReimbursementNoteAttachment.find(params[:id])
    @reimbursement_note_attachment.destroy

    respond_to do |format|
      format.html { redirect_to("/reimbursement_notes/#{@reimbursement_note_attachment.reimbursement_note_id}", :notice => 'Attachment successfully deleted.')  }
      format.json { head :ok }
    end
  end
end