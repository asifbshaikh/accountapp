class InvoiceAttachmentsController < ApplicationController
  # GET /invoice_attachments
  # GET /invoice_attachments.json
  def index
    @invoice_attachments = InvoiceAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invoice_attachments }
    end
  end

  # GET /invoice_attachments/1
  # GET /invoice_attachments/1.json
  def show
    @invoice_attachment = InvoiceAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invoice_attachment }
    end
  end

  # GET /invoice_attachments/new
  # GET /invoice_attachments/new.json
  def new
    subscription = Subscription.find_by_company_id(@company.id)
    @invoice_attachments = InvoiceAttachment.invoice_attachments(params, @company, @current_user)
 
       if @invoice_attachments.save
        redirect_to :back,:notice => 'Attachment successfully Added.'
      
      elsif subscription.utilized_storage_mb.to_i >= subscription.allocated_storage_mb.to_i 
            flash[:error] = "Storage limit reached, your plan does not allow storing any more files."
            redirect_to :back, :invoice_attachments => @invoice_attachments

      else
            flash[:error] = "Uploaded file must be pdf or image and file size between 0 and 5242880 bytes"
          redirect_to :back, :invoice_attachments => @invoice_attachments
      end
 
  end

  # GET /invoice_attachments/1/edit
  def edit
    @invoice_attachment = InvoiceAttachment.find(params[:id])
  end

  # POST /invoice_attachments
  # POST /invoice_attachments.json
  def create
    @invoice_attachment = InvoiceAttachment.new(params[:invoice_attachment])

    respond_to do |format|
      if @invoice_attachment.save
        format.html { redirect_to @invoice_attachment, notice: 'Invoice attachment was successfully created.' }
        format.json { render json: @invoice_attachment, status: :created, location: @invoice_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @invoice_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /invoice_attachments/1
  # PUT /invoice_attachments/1.json
  def update
    @invoice_attachment = InvoiceAttachment.find(params[:id])

    respond_to do |format|
      if @invoice_attachment.update_attributes(params[:invoice_attachment])
        format.html { redirect_to @invoice_attachment, notice: 'Invoice attachment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @invoice_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_attachments/1
  # DELETE /invoice_attachments/1.json
  def destroy
    
    @invoice_attachment = InvoiceAttachment.find(params[:id])
    @invoice_attachment.destroy

    respond_to do |format|
      format.html { redirect_to("/invoices/#{@invoice_attachment.invoice_id}", :notice => 'Attachment successfully deleted.')  }
      format.json { head :ok }
    end
  end
end
