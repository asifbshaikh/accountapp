class Gstr2SaveRequest < GstRequest

  ACTION = 'RETSAVE'
  HTTP_METHOD = 'Net::HTTP::Put'

  def initialize(company, gsp, usr_ip_addr, txn, gstr_two, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr_two = gstr_two
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
    add_additional_headers
  end

  def payload
 	  #generate_payload = GstrOneSerializer.new(@gstr_one).serializable_hash
    #json_formatted_payload = generate_payload.to_json
   	{'action' => ACTION, 'data' => encrypt_payload(json_payload), 'hmac' => sign_payload(json_payload)} 
  end

  def generate_payload
    @payload ||= GstrTwoSerializer.new(@gstr_two).serializable_hash
  end

  def json_payload
    @json_payload ||= generate_payload.to_json
  end

  def http_method
    HTTP_METHOD
  end

  def auth_token
    @active_session.auth_token
  end

  def request_URL
   if Rails.env.production?
       "https://gspapi.karvygst.com/returns/gstr2"
   else
   # if Rails.env.production?
   #    "https://gspapi.karvygst.com/returns/gstr2"
   #  else
      'http://gsp.karvygst.com/v0.3/returns/gstr2'
   end
  end
 
  def decrypt_sek
    @encryption_utility.decrypt_sek(@asp.app_key, @active_session.sek)
  end

  def encrypt_payload(json)
    payload_encrypted = @encryption_utility.encrypt_payload(decrypt_sek, json)
  end


  def sign_payload(json)
    puts json.inspect
    payload_signature = @encryption_utility.generate_hmac(decrypt_sek,json)
    Rails.logger.debug "payload_signature #{payload_signature}"
    payload_signature
  end

  def action
    ACTION
  end
  
  private

    def add_additional_headers
      new_header = {'username'=> @company.gstn_username, 'gstin' => @company.GSTIN ,'accept'=>@asp.content_type, 'auth-token' => auth_token, 'ret_prd' => "#{@gstr_two.month.to_s.rjust(2,'0')}#{@gstr_two.year}"}
      @headers.merge! new_header
    end

end
