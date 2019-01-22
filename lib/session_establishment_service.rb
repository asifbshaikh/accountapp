require 'net/http'
require 'openssl'
require 'base64'
require 'asp_config'


#Too many responsibilities for this class.
#Extract login establishment into separate service
#Extract reading of ASP config details into another class. This should be a singleton class.
#Extract encryption and decryption logic into separate class
#How do we determine if we have an active session?
#Replace all puts with logger statements
#Move gstn public key into database or singleton object
class SessionEstablishmentService

  #Request for OTP
  #Request for AUTH Token
  #Add Encryption Services 


#   def initialize
#   	@asp_information = AspConfig.instance
#   end

# def request_token(otp)
# 	headers = {'client-secret'=> @asp_information.client_secret,'clientid'=>@asp_information.client_id,
#     'content-type'=>  @asp_information.content_type,'ip-usr'=> @asp_information.ip_user,'state-cd'=>@asp_information.state_cd.to_s,
#     'txn'=> "#{timestamp}", 'karvyclientid'=>'profitbooks','karvyclient-secret'=>'profit123$!'}
# 	data={'username'=>	@asp_information.user_name,'action'=> 'AUTHTOKEN',
#     'app_key'=> 'DJNLyKK/XAi6ILg0L0G9t68k4+H5UyvUhEN6nr9gmnwgQf/DSAMSWL+gLcPHkD/hQHh51WwGGioCA7SC8p+Hj6S8tXFazr3a9iHiOsRTOgLBdfNI49pLL9ovhG/40iazPU2JWThRlr5DA53in/x3aGLdyhZoXwfg+ijY3C/jW28pCwXZ5TChgzzPp8WbZenRwfxCaus5JVWs+GNZW+fd7YrgeQ9DDZt/Zis71223chxmhKeawaLYgRdgxjV7E88WUExXskciwCCU9L1GwSLfGbD5nXfq4y6ZvP0WeNWp/ipS6BfgqySer5N8OlxClkdCg4n/Otkv8j/4WBvh8hDWZg==',
#     'otp' => otp}
# 	url = URI.parse("http://gsp.karvygst.com/v0.3/Authenticate")
# 	req = Net::HTTP::Post.new(url.request_uri,headers)
# 	req.body = data.to_json
# 	req['Content-Type'] = 'application/json'
# 	http = Net::HTTP.new(url.host, url.port)
# 	http.use_ssl = (url.scheme == "https")
# 	response = http.request(req)
#   Rails.logger.debug "Response from SessionEstablishmentService is  #{response.body}"
# 	response
# end


# def timestamp
# time = Time.now.strftime("%Y%m%d%H%M%S") 
# end

end
