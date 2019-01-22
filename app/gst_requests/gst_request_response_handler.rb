require 'net/http'
require 'openssl'
require 'base64'
require 'uri'
require 'asp_config'

class GstRequestResponseHandler
 
  def initialize
    #@gsp = GSP.allocate_gsp
    @asp = AspConfig.instance
  end

  def handleOTPRequest(gst_request, gst_response)
    url = fetch_URL(gst_request.request_URL)
    Rails.logger.debug "GstRequestResponseHandler::handleOTPRequest::the URL is #{gst_request.request_URL}"
    #req = Net::HTTP::Post.new(url.request_uri, otpheaders)
    Rails.logger.debug "GstRequestResponseHandler::handleOTPRequest:: headers from gst_request as #{gst_request.headers}"

    req = Net::HTTP::Post.new(url.request_uri, gst_request.headers)
    req.body = gst_request.payload.to_json
    Rails.logger.debug " The payload is #{gst_request.payload.to_json}"
    req['Content-Type'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")
    gst_response.payload(http.request(req))
  end

  def handleRequest(gst_request, gst_response)
    url = fetch_URL(gst_request.request_URL)
    Rails.logger.debug "GstRequestResponseHandler::handleRequest::the URL is #{gst_request.request_URL}"
    req_method = gst_request.http_method.constantize
    Rails.logger.debug "GstRequestResponseHandler::handleRequest:: headers from gst_request as #{gst_request.headers}"
    #req = req_method.new(url.request_uri, headers(gst_request.auth_token))
    req = req_method.new(url.request_uri, gst_request.headers)
    req.body = gst_request.payload.to_json
    Rails.logger.debug " The payload is #{gst_request.payload.to_json}"
    req['Content-Type'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.read_timeout = 30
    http.use_ssl = (url.scheme == "https")
    log_request(gst_request, Time.zone.now)
    gst_response.payload(http.request(req))
    log_response(gst_response, Time.zone.now)
  end

  private
    
    # def otpheaders
    #   {'client-secret'=> @asp.client_secret, 'clientid' => @asp.client_id, 'content-type' => @asp.content_type, 
    #     'ip-usr'=> @asp.ip_user, 'state-cd' => @asp.state_cd.to_s, 'txn' => "prftbks#{timestamp}", 
    #     'karvyclientid'=> 'profitbooks' , 'karvyclient-secret' => 'profit123$!'}
    # end

    # def headers(auth_token)
    #   {'accept'=> @asp.content_type, 'auth-token'=> auth_token, 'client-secret'=> @asp.client_secret, 'clientid' => @asp.client_id, 'content-type' => @asp.content_type, 
    #     'gstin'=> '27GSPMH4602G1ZS', 'ip-usr'=> @asp.ip_user, 'ret_prd'=> '072017', 'state-cd' => @asp.state_cd.to_s, 'txn' => "prftbks#{timestamp}", 'username'=> 'profitbooks.mh.tp.2',
    #     'karvyclientid'=> 'profitbooks' , 'karvyclient-secret' => 'profit123$!'}
    # end


    # def timestamp
    #   Time.now.strftime("%Y%m%d%H%M%S") 
    # end

    def log_request(gst_request, sent_time)
      GstRequestLog.create(company_id: gst_request.company.id, gsp_id: gst_request.gsp.id, action: gst_request.action,
        txn: gst_request.txn, payload: gst_request.json_payload, usr_ip_addr: gst_request.usr_ip_addr, sent_time: sent_time)
    end

    def log_response(gst_response, received_time)
      GstResponseLog.create(company_id: gst_response.company.id, gsp_id: gst_response.gsp.id, action: gst_response.action,
        txn: gst_response.txn, payload: gst_response.decrypt_payload, usr_ip_addr: gst_response.usr_ip_addr, received_time: received_time)
    end

    def fetch_URL(url_string)
      encoded_url =  URI.encode(url_string)
      url = URI.parse(encoded_url)      
    end

end
