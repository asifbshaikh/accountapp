class Gstr1FilingsController < ApplicationController
  require 'net/http'
  require 'login_service'
  require 'json' 


  def index
  end

  def show
    @gstr_one = @company.gstr_ones.find(params[:id])
    if !@gstr_one.blank?
      @resp_status = @gstr_one.status_name
    end
    @info = @gstr_one.gstr_one_summary
    @type =params[:type]
    @invoices =@gstr_one.company.invoices.where(:id => @gstr_one.gstr_one_items.where(:voucher_type => "Invoice").map{|item| item.voucher_id})
    # create the table entries for this return summary sections
    if @gstr_one.gstr1_summary.blank?
      gstr1_summary = Gstr1Summary.create(company_id: @company.id, gstr_one_id: @gstr_one.id, return_period: @gstr_one.return_period)
      @gstr_one.gstr1_summary = gstr1_summary
    end
    @gstr1_section_summary = @gstr_one.gstr1_summary.gstr1_section_summaries
    @b2b_summary = @gstr1_section_summary.find_by_section_type_and_gstr1_summary_id("B2B", @gstr_one.gstr1_summary.id)
    @b2b_counter_party_summary = @b2b_summary.gstr1_counter_party_summaries unless @b2b_summary.blank?
    @cdnr_summary = @gstr1_section_summary.find_by_section_type_and_gstr1_summary_id("CDNR", @gstr_one.gstr1_summary.id)
    @cdnr_counter_party_summary = @cdnr_summary.gstr1_counter_party_summaries unless @b2b_summary.blank?
    @b2cl_summary = @gstr1_section_summary.find_by_section_type_and_gstr1_summary_id("B2CL", @gstr_one.gstr1_summary.id)
    @b2cl_state_code_summary = @b2cl_summary.gstr1_state_code_summaries unless @b2b_summary.blank?
    @cdnur_summary = @gstr1_section_summary.find_by_section_type_and_gstr1_summary_id("CDNUR", @gstr_one.gstr1_summary.id)
    @cdnur_state_code_summary = @cdnur_summary.gstr1_state_code_summaries unless @b2b_summary.blank?

    respond_to do |format|
      format.html 
      format.json { render :json => GstrOneDatatable.new(view_context, @company, @current_user, @financial_year, @gstr_one, @type)}
    end
  end

def request_gross_values
  @gstr_one = @company.gstr_ones.find(params[:id])
end

def upload
  @gstr_one = @company.gstr_ones.find(params[:id])
  if @company.GSTIN.blank?
    flash[:error] = "Please update your GSTIN before filing or uploading data to GSTN"
    redirect_to gstr1_filing_path(params[:id])
  elsif @gstr_one.gross_values?
    redirect_to action: :request_gross_values, :id => @gstr_one.id
  else
    session_srv = SessionService.new(@company, nil)
    if session_srv.active_session_present?
      GstrOneUploadWorker.perform_async(@company.id, request.remote_ip, @gstr_one.id)

      respond_to do |format|
        format.html { redirect_to controller: 'gstr1_filings', action: 'processing',id: @gstr_one.id }
      end
        # redirect_to gstr1_filing_path(@gstr_one), :notice => "GSTR-1 data uploaded successfully"
      else
        redirect_to new_login_request_path(:action_value => @gstr_one.id, :action_key => "upload_gstr1")
      end
    end
  end

  def verify
    @gstr_one = @company.gstr_ones.find(params[:id])
    if @gstr_one.can_verify?
      session_srv = SessionService.new(@company, nil)
      if session_srv.active_session_present?
        Gstr1StatusWorker.perform_async(@company.id, request.remote_ip, @gstr_one.id)
        respond_to do |format|
          format.html { redirect_to controller: 'gstr1_filings', action: 'processing', id: @gstr_one.id }
        end
        # redirect_to gstr1_filing_path(@gstr_one), :notice => "GSTR-1 data uploaded successfully"
      else
        redirect_to new_login_request_path(:action_value => @gstr_one.id, :action_key => "verify_gstr1")
      end
    else
      flash[:error] = "Please upload your data to GSTN before verifying!"
      redirect_to gstr1_filing_path(params[:id])
    end
  end

  def update
   @gstr_one = @company.gstr_ones.find(params[:id])
   session_srv = SessionService.new(@company, nil)
   if session_srv.active_session_present?
    Gstr1SummaryWorker.perform_async(@company.id, request.remote_ip, @gstr_one.id)
    respond_to do |format|
      format.html { redirect_to controller: 'gstr1_filings', action: 'processing',id: @gstr_one.id }
    end
  else
    redirect_to gstr1_filing_path(params[:id])
  end

end


  # def generate_payload
  #   @gstr_one = @company.gstr_ones
  #   render json: @gstr_one,:root =>"payload"
  # end

  def fetch_data
    @gstr_one = @company.gstr_ones.find(params[:id])
    @type= params[:type]
    @general_info = @gstr_one.fetch_general_info(@type)
    respond_to do |format|
      format.js
      format.json { render :json => GstrOneDatatable.new(view_context, @company, @current_user, @financial_year,month,@type)}
    end
  end


  def update_gross_values
    @gstr_one = @company.gstr_ones.find(params[:id])
    fy_gross_turnover  = params["fy_gross_turnover"]
    qtr_gross_turnover  = params["qtr_gross_turnover"]
    if !fy_gross_turnover.blank? && !qtr_gross_turnover.blank?
      if fy_gross_turnover.to_d > 0 && qtr_gross_turnover.to_d > 0
        @save_success = @gstr_one.update_attributes(:fy_gross_turnover => fy_gross_turnover.to_d, :qtr_gross_turnover => qtr_gross_turnover.to_d)
        redirect_to gstr1_filing_path(:id => @gstr_one)
      else
        @save_success = false  
        flash.now[:error] = "Please enter valid values"
        render :request_gross_values
      end  
    end
  end


  # def submit_otp
  #   check_otp = GstrOne.check_validity_of_otp(params)
  #   @valid_otp=JSON.parse check_otp.body
  #   puts "ffffffffffff#{@valid_otp}"
  # end


  #[FIXME] Naveen - I have introduced a new status called processing as long as it is in that status
  # this page should be shown else redirect to index page
  def processing
    @gstr_one = @company.gstr_ones.find(params[:id])   
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end


  # def gstr1_filing
  #   payload = generate_payload
  #   RequestLog.save_gstr1_filing_payload(payload, @company)
  # end

end
