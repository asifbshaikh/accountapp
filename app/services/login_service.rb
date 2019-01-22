require 'asp_config'
require 'securerandom'

class LoginService

  def initialize(company, username)
    @company = company
    @username = username
    @gsp = Gsp.allocate_gsp
    @asp = AspConfig.instance
    @requestHandler = GstRequestResponseHandler.new
  end

  def request_new_otp(usr_ip_addr)
    txn = transaction_number 
    request = GstOtpRequest.new(@company, @gsp, usr_ip_addr, txn)
    response = GstOtpResponse.new(@company, @gsp, usr_ip_addr, txn)
    @requestHandler.handleOTPRequest(request, response)
    response.success?
  end

  private
    def transaction_number
      "prftbk#{SecureRandom.hex(12)}"
    end

end
