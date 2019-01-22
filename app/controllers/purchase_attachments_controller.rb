class PurchaseAttachmentsController < ApplicationController
  # skip_before_filter :authorize_action
  # GET /purchase_attachments
  # GET /purchase_attachments.json
  def index
    @purchase_attachments = PurchaseAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_attachments }
    end
  end

  # GET /purchase_attachments/1
  # GET /purchase_attachments/1.json
  def show
   @purchase_attachment = PurchaseAttachment.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase_attachment }
    end
  end

  # GET /purchase_attachments/new
  # GET /purchase_attachments/new.json
  def new
     @purchase_attachments = PurchaseAttachment.purchase_attachments(params, @company, @current_user)
      subscription = Subscription.find_by_company_id(@company.id)

      if @purchase_attachments.save
        redirect_to :back,:notice => 'Attachment successfully Added.'
       
        elsif subscription.utilized_storage_mb.to_i >= subscription.allocated_storage_mb.to_i 
            flash[:error] = "Storage limit reached, your plan does not allow storing any more files."
            redirect_to :back, :purchase_attachments => @purchase_attachments

      else
            flash[:error] = "Uploaded file must be pdf or image and file size between 0 and 5242880 bytes"
          redirect_to :back, :purchase_attachments => @purchase_attachments
      end
  end

  # GET /purchase_attachments/1/edit
  def edit
    @purchase_attachment = PurchaseAttachment.find(params[:id])
  end

  # POST /purchase_attachments
  # POST /purchase_attachments.json
  def create
    @purchase_attachment = PurchaseAttachment.new(params[:purchase_attachment])

    respond_to do |format|
      if @purchase_attachment.save
        format.html { redirect_to @purchase_attachment, notice: 'Purchase attachment was successfully created.' }
        format.json { render json: @purchase_attachment, status: :created, location: @purchase_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @purchase_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_attachments/1
  # PUT /purchase_attachments/1.json
  def update
    @purchase_attachment = PurchaseAttachment.find(params[:id])

    respond_to do |format|
      if @purchase_attachment.update_attributes(params[:purchase_attachment])
        format.html { redirect_to @purchase_attachment, notice: 'Purchase attachment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @purchase_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_attachments/1
  # DELETE /purchase_attachments/1.json
  def destroy
    @purchase_attachment = PurchaseAttachment.find(params[:id])
    @purchase_attachment.destroy

    respond_to do |format|
      format.html { redirect_to("/purchases/#{@purchase_attachment.purchase_id}", :notice => 'Attachment successfully deleted.')  }
      format.json { head :ok }
    end
  end
end
