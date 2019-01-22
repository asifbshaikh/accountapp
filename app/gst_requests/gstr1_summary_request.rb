class Gstr1SummaryRequest < GstRequest

  ACTION = 'RETSUM'
  HTTP_METHOD = 'Net::HTTP::Get'

  def initialize(company, gsp, usr_ip_addr, txn, gstr1_summary, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr1_summary = gstr1_summary
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
      "https://gspapi.karvygst.com/returns/gstr1?action=#{ACTION}&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}"
      #"https://gspapi.karvygst.com/returns/gstr1?action=RETSTATUS&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}&ref_id=#{@gstr1_summary.gstr_one.gst_reference}"
    else
      "http://gsp.karvygst.com/v0.3/returns/gstr1?action=#{ACTION}&gstin=#{@company.GSTIN}&ret_period=#{@gstr1_summary.return_period}"      
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
      new_header = {'username'=> @company.gstn_username, 'gstin' => @company.GSTIN , 'auth-token' => auth_token, 'ret_prd' => @gstr1_summary.return_period}
      @headers.merge! new_header
    end


end
