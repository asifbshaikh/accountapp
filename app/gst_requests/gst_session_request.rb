require "encryption_utility"

class GstSessionRequest < GstRequest

  ACTION = 'AUTHTOKEN'

  def initialize(company, gsp, usr_ip_addr, txn, otp)
    super(company, gsp, usr_ip_addr, txn)
    @otp = otp
    @encryption_utility = EncryptionUtility.new()
  end

  def payload
    {'username' => @company.gstn_username, 'action' => ACTION, 'app_key' => @asp.encrypted_app_key, 'otp' => encrypt_otp}
  end

  def request_URL
    # if Rails.env.production?
    #   "https://gspapi.karvygst.com/Authenticate"
    # else
      'http://gsp.karvygst.com/v0.3/Authenticate'
    # end
  end

  def encrypt_otp
    @encryption_utility.encrypt_otp(@otp)
  end

end