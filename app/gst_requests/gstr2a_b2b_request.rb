class Gstr2aB2bRequest < GstRequest

  ACTION = 'B2B'
  HTTP_METHOD = 'Net::HTTP::Get'

  def initialize(company, gsp, usr_ip_addr, txn, gstr2a, active_session, ctin)
    super(company, gsp, usr_ip_addr, txn)
    @gstr2a = gstr2a
    @ctin = ctin
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
    add_additional_headers
  end

  def payload
    #json_payload
  end

  #this method is required for request logging
  def json_payload
    request_URL
  end

  def http_method
    HTTP_METHOD
  end

  def auth_token
    @active_session.auth_token
  end

  def request_URL
    if Rails.env.production?
      #"https://gspapi.karvygst.com/returns/gstr1?action=#{ACTION}&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}"
      #{}"https://gspapi.karvygst.com/returns/gstr1?action=RETSTATUS&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}&ref_id=#{@gstr1_summary.gstr_one.gst_reference}"
    else
      "http://gsp.karvygst.com/v0.3/returns/gstr2a?action=#{ACTION}&gstin=27GSPMH4602G1ZS&ret_period=#{@gstr2a.return_period}&ctin=#{@ctin}"
      #"http://gsp.karvygst.com/v0.3/returns/gstr2a?action=B2B&gstin=18AFIPM8653AIZ9&ret_period=072017&ctin=27GSPMH4602G1ZS"
      #"http://gsp.karvygst.com/v0.3/returns/gstr1?action=B2B&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}&action_required=Y&ctin=33AAACE9665J1ZD&from_time=01-09-2017"
      #{}"http://gsp.karvygst.com/v0.3/returns?action=RETSTATUS&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}&ref_id=#{@gstr1_summary.gstr_one.gst_reference}"
      #"http://gsp.karvygst.com/v0.3/returns?action=RETSTATUS&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}&ref_id=d0aea90e-d730-4e36-8731-7ff11232f08d"
    end
  end
 
  def decrypt_sek
    @encryption_utility.decrypt_sek(@asp.app_key, @active_session.sek)
  end

  def encrypt_payload(json)
    payload_encrypted = @encryption_utility.encrypt_payload(decrypt_sek, json)
  end


  def sign_payload(json)
    payload_signature = @encryption_utility.generate_signature(decrypt_sek,json)
    Rails.logger.debug "payload_signature #{payload_signature}"
    payload_signature
  end

  def action
    ACTION
  end

    private

    def add_additional_headers
      new_header = {'username'=> @company.gstn_username, 'gstin' => @company.GSTIN , 'auth-token' => auth_token, 'ret_prd' => @gstr2a.return_period}
      @headers.merge! new_header
    end

end