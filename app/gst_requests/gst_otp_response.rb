class GstOtpResponse < GstResponse

  def initialize(company, gsp, usr_ip_addr, txn)
    super(company, gsp, usr_ip_addr, txn)
  end
  
  # def payload(data)
  #   #parse the payload and do processing
  #   @payload = JSON.parse data.body
  # end

  # def success?
  #   @payload["success"] == 1
  # end


end
