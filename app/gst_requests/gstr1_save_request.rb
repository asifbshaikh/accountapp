class Gstr1SaveRequest < GstRequest

  ACTION = 'RETSAVE'
  HTTP_METHOD = 'Net::HTTP::Put'

  def initialize(company, gsp, usr_ip_addr, txn, gstr_one, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr_one = gstr_one
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
    add_additional_headers
  end

  def payload
 	  #generate_payload = GstrOneSerializer.new(@gstr_one).serializable_hash
    #json_formatted_payload = generate_payload.to_json
   	@payload ||= {'action' => ACTION, 'data' => encrypt_payload(json_payload), 'hmac' => sign_payload(json_payload)} 
  end

  def generate_payload
    @payload ||= GstrOneSerializer.new(@gstr_one).serializable_hash
  end

  def json_payload
    @json_payload ||= generate_payload.to_json
    #'{"gstin" : "27GSPMH4602G1ZS", "fp" : "072017", "gt" : 1234567.89, "cur_gt" : 12345.67, "b2b" : [ {"ctin" : "33AAACE9665J1ZD", "inv" : [ {"inum" : "INV000040000001", "idt" : "04-07-2017", "val" : 12400, "pos" : "33",  "rchrg" : "N", "inv_typ" : "R", "itms" : [{ "num" : 1, "itm_det" : { "rt" : 12.00, "txval" : 1000.00,  "iamt" : 120.00}}]}]}]}'
    #'{"gstin": "27GSPMH4602G1ZS", "fp": "072017", "gt": 7600000.0, "cur_gt": 7600000.0, "b2b": [{"ctin": "33GSPTN0832G1ZF", "inv": [{"inum": "PO10117185", "idt": "06-07-2017", "val": 437961.28,  "pos": "33","rchrg": "N", "inv_typ": "R", "itms": [{"num": 1, "itm_det": {"rt": 5.00, "txval": 25000.0,"camt": 625.0,"samt": 625.0, "csamt": 0.0 }}, {  "num": 2,"itm_det": { "rt": 12.00,"txval": 1000.0,"camt": 60.0,"samt": 60.0,  "csamt": 0.0}}, {"num": 3, "itm_det": {"rt": 18.00,"txval": 100000.0,"camt": 9000.0, "samt": 9000.0, "csamt": 0.0}}]}]}]}'
  end

  def http_method
    HTTP_METHOD
  end

  def auth_token
    @active_session.auth_token
  end

  def request_URL
    # if Rails.env.production?
    #   "https://gspapi.karvygst.com/returns/gstr1"
    # else
      'http://gsp.karvygst.com/v0.3/returns/gstr1'
    # end
  end
 
  def decrypt_sek
    @ek ||= @encryption_utility.decrypt_sek(@asp.app_key, @active_session.sek)
  end

  def encrypt_payload(json)
    Rails.logger.debug "Gstr1SaveRequest::encrypt_payload:: The payload is #{json}"
    payload_encrypted = @encryption_utility.encrypt_payload(decrypt_sek, json)
  end


  def sign_payload(json)
    payload_signature = @encryption_utility.generate_hmac(decrypt_sek, json)
    Rails.logger.debug "payload_signature #{payload_signature}"
    payload_signature
  end

  def action
    ACTION
  end
  
  private

    def add_additional_headers
      new_header = {'username'=> @company.gstn_username, 'gstin' => @company.GSTIN, 'accept'=>@asp.content_type,
       'auth-token' => auth_token, 'ret_prd' => "#{@gstr_one.return_period}"}
      @headers.merge! new_header
    end

end
