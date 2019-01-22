class Gstr2asController < ApplicationController
  # GET /gstr2as
  # GET /gstr2as.json
  def index
    @gstr2as = Gstr2a.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gstr2as }
    end
  end

  # GET /gstr2as/1
  # GET /gstr2as/1.json
  def show
    #@gstr2a = Gstr2a.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gstr2a }
    end
  end

  # GET /gstr2as/new
  # GET /gstr2as/new.json
  def new
    @gstr2a = Gstr2a.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gstr2a }
    end
  end

  # GET /gstr2as/1/edit
  def edit
    @gstr2a = Gstr2a.find(params[:id])
  end

  # POST /gstr2as
  # POST /gstr2as.json
  def create
    @gstr2a = Gstr2a.new(params[:gstr2a])

    respond_to do |format|
      if @gstr2a.save
        format.html { redirect_to @gstr2a, notice: 'Gstr2a was successfully created.' }
        format.json { render json: @gstr2a, status: :created, location: @gstr2a }
      else
        format.html { render action: "new" }
        format.json { render json: @gstr2a.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gstr2as/1
  # PUT /gstr2as/1.json
  def update
    @gstr2a = Gstr2a.find(params[:id])

    respond_to do |format|
      if @gstr2a.update_attributes(params[:gstr2a])
        format.html { redirect_to @gstr2a, notice: 'Gstr2a was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gstr2a.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gstr2as/1
  # DELETE /gstr2as/1.json
  def destroy
    @gstr2a = Gstr2a.find(params[:id])
    @gstr2a.destroy

    respond_to do |format|
      format.html { redirect_to gstr2as_url }
      format.json { head :ok }
    end
  end

  # def upload
  #   logger.debug "id is #{@company.id}======================================================================="
  #   @gstr2a = Gstr2a.find(params[:id])
  #   #@gstr2a = Gstr2a.find(389)
  #   purchases = @company.purchases.where(:id => @company.gstr_two_items.where(:voucher_classification => 'B2B',:voucher_type => 'Purchase').map{|item| item.voucher_id})
  #   ctin_hash = Hash.new
  #   purchases.each do |p|
  #     gstin = p.vendor.GSTIN
  #     if !ctin_hash.has_key? gstin
  #       ctin_hash[gstin] = gstin
  #     end
  #   end  
  #   logger.debug "gstr2a_controller::upload:The unique GSTINs are #{ctin_hash.inspect}==============="
      
  #   if @company.GSTIN.blank?
  #     flash[:error] = "Please update your GSTIN before filing or uploading data to GSTN"
  #     redirect_to gstr2_filing_path(params[:id])
  #   else
  #     session_srv = SessionService.new(@company,nil)
  #     if session_srv.active_session_present?
  #       ctin_hash.values.each do |ctin|
  #         Gstr2aWorker.perform_async(@company.id, request.remote_ip, @gstr2a.id, ctin)
  #       end  
  #       respond_to do |format|
  #         format.html { redirect_to controller: 'gstr2as', action: 'processing',id: @gstr2a.id }
  #       end
  #       # redirect_to gstr1_filing_path(@gstr_two), :notice => "GSTR-1 data uploaded successfully"
  #     else
  #       Rails.logger.debug " The upload has failed "
  #       redirect_to new_login_request_path(:action_value => @gstr2a.id, :action_key => "upload_gstr2")
  #     end
  #   end
  # end

  def processing 
  end
end
