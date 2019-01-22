require 'session_establishment_service'
class LoginRequestsController < ApplicationController
  # GET /login_requests
  # GET /login_requests.json
  def index
    @login_requests = LoginRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @login_requests }
    end
  end

  # GET /login_requests/1
  # GET /login_requests/1.json
  def show
    @login_request = LoginRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @login_request }
    end
  end

  # GET /login_requests/new
  # GET /login_requests/new.json
  def new
    @login_request = LoginRequest.new
    @login_srvc = LoginService.new(@company, @company.gstn_username)
    logger.debug "before making the OTP request call"
    if @login_srvc.request_new_otp(request.remote_ip)
    else
      flash[:notice] = "Unable to connect to GSTN system"
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @login_request }
    end
  end

  # GET /login_requests/1/edit
  def edit
    @login_request = LoginRequest.find(params[:id])
  end

  # POST /login_requests
  # POST /login_requests.json
  def create
    @login_request = LoginRequest.new(params[:login_request])
    @session_srvc = SessionService.new(@company, nil)
    respond_to do |format|
      if @session_srvc.request_session(params[:otp], request.remote_ip)
        logger.debug " #{params[:action_key]} and #{params[:action_value]}"
        key = params[:action_key]
        value = params[:action_value]
        if key == "upload_gstr1"
          format.html { redirect_to :controller => "gstr1_filings", :action=> :upload, :id => value }
        elsif key == "gstr1_summary"
          format.html { redirect_to :controller => "gstr1_summaries", :action=> :fetch, :id => value }
       elsif key == "upload_gstr2"
          format.html { redirect_to :controller => "gstr2_filing", :action=> :upload, :id => value }
        else
          format.html { render action: "new" }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @login_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /login_requests/1
  # PUT /login_requests/1.json
  def update
    @login_request = LoginRequest.find(params[:id])

    respond_to do |format|
      if @login_request.update_attributes(params[:login_request])
        format.html { redirect_to @login_request, notice: 'Login request was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @login_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /login_requests/1
  # DELETE /login_requests/1.json
  def destroy
    @login_request = LoginRequest.find(params[:id])
    @login_request.destroy

    respond_to do |format|
      format.html { redirect_to login_requests_url }
      format.json { head :ok }
    end
  end
end
