class Gstr2FilingController < ApplicationController
 

  def index
  end

  def show
    @gstr_two = @company.gstr_twos.find(params[:id])
    @type = params[:type]
    @general_info = @gstr_two.fetch_general_info(@type)
    @gstr_two_items = @gstr_two.gstr_two_items
    #@info = @gstr_two.itc_details
    #create the table entries for this return summary sections
    if @gstr_two.gstr2_summary.blank?
      gstr2_summary = Gstr2Summary.create(company_id: @company.id, gstr_two_id: @gstr_two.id, return_period: @gstr_two.return_period)
      @gstr_two.gstr2_summary = gstr2_summary
    end
    respond_to do |format|
      format.html #show.html.erb
      format.json { render :json => GstrTwoDatatable.new(view_context, @company, @current_user, @financial_year, @gstr_two, @type)}
    end
  end

  def request_gross_values
    @gstr_two = GstrTwo.find(params[:id])
  end

  def upload
    @gstr_two = GstrTwo.find(params[:id])
    if @company.GSTIN.blank?
      flash[:error] = "Please update your GSTIN before filing or uploading data to GSTN"
      redirect_to gstr2_filing_path(params[:id])
    #elsif @gstr_two.gross_values?
     # redirect_to action: :request_gross_values, :id => @gstr_two.id
    else
      session_srv = SessionService.new(@company, nil)
      if session_srv.active_session_present?
        GstrTwoUploadWorker.perform_async(@company.id, request.remote_ip, @gstr_two.id)

        respond_to do |format|
          format.html { redirect_to controller: 'gstr2_filing', action: 'processing',id: @gstr_two.id }
        end
        # redirect_to gstr2_filing_path(@gstr_two), :notice => "GSTR-2 data uploaded successfully"
      else
        redirect_to new_login_request_path(:action_value => @gstr_two.id, :action_key => "upload_gstr2")
      end
    end
  end

  def verify
    @gstr_two = @company.gstr_twos.find(params[:id])
    if @gstr_two.can_verify?
      session_srv = SessionService.new(@company, nil)
      if session_srv.active_session_present?
        Gstr2StatusWorker.perform_async(@company.id, request.remote_ip, @gstr_two.id)
        respond_to do |format|
          format.html { redirect_to controller: 'gstr2_filing', action: 'processing', id: @gstr_two.id }
        end
       
      else
        redirect_to new_login_request_path(:action_value => @gstr_two.id, :action_key => "verify_gstr2")
      end
    else
      flash[:error] = "Please upload your data to GSTN before verifying!"
      redirect_to gstr2_filing_path(params[:id])
    end
  end

    def summary
         @gstr_two = @company.gstr_twos.find(params[:id])

        if @gstr_two.can_verify?
          session_srv = SessionService.new(@company, nil)
          if session_srv.active_session_present?
            Gstr2SummaryWorker.perform_async(@company.id, request.remote_ip, @gstr_two.id)
               respond_to do |format|
               format.html { redirect_to controller: 'gstr2_filing', action: 'processing', id: @gstr_two.id }
               end
            else
              redirect_to new_login_request_path(:action_value => @gstr_two.id, :action_key => "summary_gstr2")
            end
          else
             flash[:error] = "Please upload your data to GSTN  & verify before summary!"
              redirect_to gstr2_filing_path(params[:id])
         end

    end

  # def generate_payload
  #   @gstr_two = @company.gstr_ones
  #   render json: @gstr_two,:root =>"payload"
  # end

  def fetch_data
    @gstr_two = GstrTwo.find(params[:id])
    @type= params[:type]
    @general_info = @gstr_two.fetch_general_info(@type)
    respond_to do |format|
      format.js
      format.json { render :json => GstrTwoDatatable.new(view_context, @company, @current_user, @financial_year,month,@type)}
    end
  end


  def update_gross_values
    @gstr_two = GstrTwo.find(params[:id])
    fy_gross_turnover  = params["fy_gross_turnover"]
    qtr_gross_turnover  = params["qtr_gross_turnover"]
    if !fy_gross_turnover.blank? && !qtr_gross_turnover.blank?
      if fy_gross_turnover.to_d > 0 && qtr_gross_turnover.to_d > 0
        @save_success = @gstr_two.update_attributes(:fy_gross_turnover => fy_gross_turnover.to_d, :qtr_gross_turnover => qtr_gross_turnover.to_d)
        redirect_to gstr1_filing_path(:id => @gstr_two)
      else
        @save_success = false  
        flash.now[:error] = "Please enter valid values"
        render :request_gross_values
      end  
    end
  end


  # def submit_otp
  #   check_otp = GstrTwo.check_validity_of_otp(params)
  #   @valid_otp=JSON.parse check_otp.body
  #   puts "ffffffffffff#{@valid_otp}"
  # end


  #[FIXME] Naveen - I have introduced a new status called processing as long as it is in that status
  # this page should be shown else redirect to index page
  def processing
    @gstr2_id = params[:id].to_i
    @gstr2_upload_check = GstrTwo.check_gstr2_upload_status(@company.id, @gstr2_id)
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end

  def fetch_gstr2a_b2b
    logger.debug "id is #{@company.id}======================================================================="
    @gstr_two = GstrTwo.find(params[:gstr_two_id])
    #@gstr_two = @company.gstr_twos.find(params[:id])
    #@gstr2a = Gstr2a.find(389)
    #purchases = @company.purchases.where(:id => @company.gstr_two_items.where(:voucher_classification => 'B2B',:voucher_type => 'Purchase').map{|item| item.voucher_id})
    logger.debug "Gstr2FilingController::fetch_gstr2a_b2b:: The Purchase voucher_classification is #{GstrTwo::PURCHASE_CLASSIFICATION[:B2B]}====="
    gstr_two_items = @gstr_two.fetch_items("B2B")
    logger.debug "Gstr2FilingController::fetch_gstr2a_b2b:: The gstr_two_items retrieved are #{gstr_two_items.inspect}============"
    ctin_hash = Hash.new
    gstr_two_items.each do |p|
      gstin = p.voucher.customer_GSTIN
      if !ctin_hash.has_key? gstin
        ctin_hash[gstin] = gstin
      end
    end  
    logger.debug "gstr2a_controller::upload:The unique GSTINs are #{ctin_hash.inspect}==============="
      
    if @company.GSTIN.blank?
      flash[:error] = "Please update your GSTIN before filing or uploading data to GSTN"
      redirect_to gstr2_filing_path(params[:id])
    else
      session_srv = SessionService.new(@company,nil)
      if session_srv.active_session_present?
        ctin_hash.values.each do |ctin|
          Gstr2aWorker.perform_async(@company.id, request.remote_ip, @gstr_two.id, ctin)
        end 
        respond_to do |format|
          format.html { redirect_to controller: 'gstr2_filing', action: 'show', id: @gstr_two.id, :anchor => "gstr2a-tab" }
        end
        # redirect_to gstr1_filing_path(@gstr_two), :notice => "GSTR-1 data uploaded successfully"
      else
        Rails.logger.debug " The upload has failed "
        redirect_to new_login_request_path(:action_value => @gstr_two.id, :action_key => "upload_gstr2")
      end
    end
  end


  # def gstr1_filing
  #   payload = generate_payload
  #   RequestLog.save_gstr1_filing_payload(payload, @company)
  # end

end
