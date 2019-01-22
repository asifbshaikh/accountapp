class GstOtpRequest < GstRequest
  
  ACTION = 'OTPREQUEST'

  def initialize(company, gsp, usr_ip_addr, txn)
    super(company, gsp, usr_ip_addr, txn)
  end

  def payload
    {'username' => @company.gstn_username, 'action' => ACTION, 'app_key' => @asp.encrypted_app_key}
  end

  def request_URL
    # if Rails.env.production?
    #   "https://gspapi.karvygst.com/Authenticate"
    # else
      "http://gsp.karvygst.com/v0.3/Authenticate"
    # end
  end
end