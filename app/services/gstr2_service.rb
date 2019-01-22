require 'net/http'
require 'json'

class Gstr2Service

  def initialize(company, usr_ip_addr, gstrtwo)
    @company = company
    @usr_ip_addr = usr_ip_addr
    @asp = AspConfig.instance
    @gsp = Gsp.allocate_gsp
    @gstr_two = gstrtwo
    #@sek='QKuc3NB80rozGyu2vzKkmeTT+Cfmia9Jkap5E/i8eSyQ3WbNGTzS7xt7HX7h92LC'
    @requestHandler = GstRequestResponseHandler.new
  end


  def save_gstr_two
    @gstr_two.processing
    txn = transaction_number
    session_srvc = SessionService.new(@company, nil)
    if session_srvc.active_session_present?
      @active_session = session_srvc.fetch_active_session
      request = Gstr2SaveRequest.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session)
      #Rails.logger.debug " The request payload is #{request.payload}"
      response = Gstr2SaveResponse.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session)
      response.txn = txn
      @requestHandler.handleRequest(request,response)
      if response.success?
        #set the gstr_status as uploaded
        @gstr_two.uploaded(response.reference_id)
        Rails.logger.debug "Gstr2Service::save_gstr_two::The reference_id is #{response.reference_id}"
      end
    end
    response.success?
  end

  def return_status
    return_status = false
    txn = transaction_number
    session_srvc = SessionService.new(@company, nil)
    if session_srvc.active_session_present?
      @active_session = session_srvc.fetch_active_session
      request = Gstr2StatusRequest.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session)
      Rails.logger.debug" The request payload is #{request.payload}"
      response = Gstr2StatusResponse.new(@company, @gsp, @usr_ip_addr, txn, @gstr_two, @active_session)
      begin
        @requestHandler.handleRequest(request, response)
        if response.success?
          Rails.logger.debug "Gstr2Service::return_status::The payload is #{response.hash_payload.inspect}"
          gstr2_status_response_handler = Gstr2StatusResponseHandler.new(@company, @gstr_two, response.hash_payload)
          gstr2_status_response_handler.process
          # set the gstr_status as uploaded
          # @gstr_two.uploaded(response.reference_id)
          # Rails.logger.debug "Gstr2Service::save_gstr_two::The reference_id is #{response.reference_id}"
         # @gstr_two.verified
          return_status = true
        end
      rescue Exception => e
        Sidekiq.logger.error e
       # ErrorMailer.gst_experror(e, request, response, @company.users.first, "Gstr2Service::save_gstr_two").deliver
      end   
    end
    return_status
  end

  def update_summary
   gstr2_summary = @gstr_two.gstr2_summary
   gstr2_summary.processing
    txn = transaction_number
    session_srvc = SessionService.new(@company, nil)
    if session_srvc.active_session_present?
      @active_session = session_srvc.fetch_active_session
      request =Gstr2SummaryRequest.new(@company, @gsp, @usr_ip_addr, txn,gstr2_summary, @active_session)
      Rails.logger.debug " The request payload is #{request.payload}"
      response =Gstr2SummaryResponse.new(@company, @gsp, @usr_ip_addr, txn,gstr2_summary, @active_session)
      begin
        @requestHandler.handleRequest(request, response)
        if response.success?
          #set the gstr_status as uploaded
          Rails.logger.warn "The response object :: #{response.inspect}"
         gstr2_summary.update_summary(response)
          Rails.logger.debug "Gstr2Service::update_summary::The Gstr2 Summary is updated"
        else 
          Rails.logger.error "Gstr2Service::update_summary::The Gstr2 Summary failed with response #{response.inspect}"
        end
      rescue Exception => e
       gstr2_summary.failed
        Sidekiq.logger.error "Gstr2Service::update_summary:: The error is #{e}"
        #ErrorMailer.gst_experror(e, request, response, @company.users.first, "Gstr1Service::save_gstr_one").deliver
      end           
    end
  end

  private
    def transaction_number
      "prftbk#{SecureRandom.hex(12)}"
    end

#  auth_token = '6579db1dab0e44d688e17afa7f38cd9b' ### hard coded need to be removed
# sek = 'QKuc3NB80rozGyu2vzKkmeTT+Cfmia9Jkap5E/i8eSyQ3WbNGTzS7xt7HX7h92LC'#hard coded need to be removed

# payload_utility = EncryptionUtility.new()
# ek = payload_utility.decrypt_sek(sek)
# puts "ek#{ek}"
# payload_signature = payload_utility.generate_signature(ek,payload)
# puts "payload_signature #{payload_signature}"

# payload_encrypted = payload_utility.encrypt_gstr1_data(ek,payload)
#  puts "payload_encrypted#{payload_encrypted}"

# headers={'accept'=> 'application/json','auth-token'=> auth_token,'client-secret'=> '29b560eab35a4e42a97a37c03ddbb57a','clientid'=> 'l7xx347ad87258aa48ebb61fcbdab7d19b0b','content-type'=> ' application/json','gstin'=> '27GSPMH4602G1ZS','ip-usr'=>'54.209.49.128','ret_prd'=> '022017','state-cd'=>'27','txn'=> 'TXN789123456789','username'=>'profitbooks.mh.tp.2','karvyclient-secret'=>'profit123$!','karvyclientid'=>'profitbooks'}
# data={'action' => 'RETSAVE','data' => payload_encrypted,
# 'hmac' => payload_signature #replace with hmac
# } 
# url = URI.parse("http://gsp.karvygst.com/v0.3/returns/gstr1") # replace with url
# puts "lllllllllllll"
# puts url
# req = Net::HTTP::Put.new(url.request_uri,headers)
# req.body =data.to_json
# req['Content-Type'] = 'application/json'
# http = Net::HTTP.new(url.host, url.port)
# http.use_ssl = (url.scheme == "https")
# response = http.request(req)
# puts response.body
# end

end
