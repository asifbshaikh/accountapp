require 'net/http'
require 'json'

class Gstr1SaveService


  def initialize(company, gstrone)
    @company = company
    @asp = AspConfig.instance
    # @gsp = gsp.blank? ? Gsp.allocate_gsp : gsp
    @gstrone = gstrone
    @sek='CyBlaI7rCCJX+Xz1BW220RNjvm/GNcGhbWTVCDxWAFSQ3WbNGTzS7xt7HX7h92LC'
    @requestHandler = GstRequestResponseHandler.new
  end


  def save_gstr_one


  	request = Gstr1SaveRequest.new(@company, @asp,@gstrone,@sek)
  	Rails.logger.debug "jjjjjjjjjjjjjj"
  	Rails.logger.debug "gggggggggggg#{request.payload}"
    response = Gstr1SaveResponse.new
    http_method = 'Net::HTTP::Put'
    @requestHandler.handleRequest(request, response,http_method)
     if response.success?
      puts "eurekkkkkkkkkkkkkkka"
      #store the requet for gstr1 save in RequestLog
      gstr1_request_log = RequestLog.new(txn_id: 123, gsp_id: 1,gst_action_id: 1 ,company_id: @company.id,status: 1,request_payload: request.payload)
      gstr1_request_log.save!
      gstr1_response_log = ResponseLog.new(txn_id:123 ,request_log_id: gstr1_request_log.id,response_payload: response.payload)
      gstr1_response_log.save!    
    end
    response.success?
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
