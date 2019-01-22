class Gstr2StatusRequest < GstRequest

  ACTION = 'RETSTATUS'
  HTTP_METHOD = 'Net::HTTP::Get'

  def initialize(company, gsp, usr_ip_addr, txn, gstr_two, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr_two = gstr_two
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
    add_additional_headers
  end

  def payload
    #generate_payload = GstrOneSerializer.new(@gstr_two).serializable_hash
    #json_formatted_payload = generate_payload.to_json
    {} 
  end

  #We keep this method due to entries in gst_request_logs table done by requestResponsehandler
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
      "https://gspapi.karvygst.com/returns?action=#{ACTION}&gstin=#{@company.GSTIN}&ret_period=#{@gstr_two.return_period}&ref_id=#{@gstr_two.gst_reference}"
    else
      "http://gsp.karvygst.com/v0.3/returns?action=#{ACTION}&gstin=#{@company.GSTIN}&ret_period=#{@gstr_two.return_period}&ref_id=#{@gstr_two.gst_reference}"
    end
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
