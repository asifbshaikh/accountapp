require 'asp_config'
require 'securerandom'

class SessionService

  def initialize(company, gsp)
    @company = company
    @asp = AspConfig.instance
    @gsp = gsp.blank? ? Gsp.allocate_gsp : gsp
    @requestHandler = GstRequestResponseHandler.new
  end

  #check if active session is present
  def active_session_present?
    Rails.logger.debug "SessionService::active_session_present::BEGIN"
    current_time = Time.now
    active_session = @company.active_sessions.where(:company_id => @company.id).where(" ? > start_time and ? < end_time", current_time, current_time)
    active_session.present?
  end

  #return the active session
  def fetch_active_session
    Rails.logger.debug "SessionService::fetch_active_session::BEGIN"    
    current_time = Time.now
    active_session = @company.active_sessions.where(:company_id => @company.id).where(" ? > start_time and ? < end_time", current_time, current_time).first
  end

  def request_session(otp, usr_ip_addr)
    txn = transaction_number
    request = GstSessionRequest.new(@company, @gsp, usr_ip_addr, txn, otp)
    response = GstSessionResponse.new(@company, @gsp, usr_ip_addr, txn)
    @requestHandler.handleOTPRequest(request, response)
    if response.success?
      #store the SEK and the auth token in the activesession table
      active_session = ActiveSession.new(company_id: @company.id, gsp_id:@gsp.id , auth_token: response.auth_token, 
        expiry: response.expiry, start_time: response.start_time, end_time: response.end_time, 
        sek: response.session_key)
      active_session.save!
    end
    response.success?
  end

  private
    def transaction_number
      Rails.logger.debug "SessionService::transaction_number::BEGIN the securerandom is #{SecureRandom.uuid}"
      "prftbk#{SecureRandom.hex(12)}"
    end

end