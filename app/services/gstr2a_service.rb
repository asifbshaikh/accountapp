require 'net/http'
require 'json'

class Gstr2aService

	def initialize(company, usr_ip_addr, gstr_two, ctin)
		@company = company
		@usr_ip_addr = usr_ip_addr
    #@asp = AspConfig.instance
    @gsp = Gsp.allocate_gsp
    @gstr_two = gstr_two
    @ctin = ctin
    @requestHandler = GstRequestResponseHandler.new
  end

  def request_cdn

  end

  def request_b2b
    Rails.logger.debug " entered request_b2b=============================================================="
    @gstr_two.processing
    txn = transaction_number
    session_srvc = SessionService.new(@company, nil)
    if session_srvc.active_session_present?
      @active_session = session_srvc.fetch_active_session
      request = Gstr2aB2bRequest.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session, @ctin)
      Rails.logger.debug " The request payload is #{request.payload} ROHITDESHPANDE"
      response = Gstr2aB2bResponse.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session)
      Rails.logger.debug "entered VISHU=============================================================="
      #Rails.logger.debug " The response payload is #{response.payload}=============================================================="
      begin
        @requestHandler.handleRequest(request, response)
        Rails.logger.debug "entered VISHU=============================================================="
        if response.success?
          Rails.logger.debug "entered VISHU=============================================================="
          #set the gstr_status as uploaded
          Rails.logger.warn "ROHITDESHPANDE The response object :: #{response.inspect}"
          #gstr_two.update_summary(response)
          Rails.logger.debug "Gstr2aService::update_summary::The GSTR2a requested"
        elsif response.errors?
          Rails.logger.error "Gstr2aService::update_summary::The GSTR2a request failed with response #{response.inspect}==========================================="
        end
      rescue Exception => e
        #@gstr_two.failed
        Sidekiq.logger.error "Gstr2aService::update_summary:: The error is #{e}"
        #ErrorMailer.gst_experror(e, request, response, @company.users.first, "Gstr1Service::save_gstr_one").deliver
      end           
    end
  end

  private
    def transaction_number
      "prftbk#{SecureRandom.hex(12)}"
    end
end