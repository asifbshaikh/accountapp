class GstResponse 

  def initialize(company, gsp, usr_ip_addr, txn)
    @company = company
    @gsp = gsp
    @asp = AspConfig.instance
    @usr_ip_addr = usr_ip_addr
    @txn = txn
  end

  attr_accessor :company, :gsp, :asp, :usr_ip_addr, :txn

  def payload(data)
    Rails.logger.warn "=============GstResponse::payload:: The response payload is #{data.body}"
    #parse the payload and do processing
    @payload = JSON.parse data.body
    check_errors
  end

  def success?
    @payload['status_cd'] == "1"
  end

  def errors?
    @payload['status_cd'] == "0"
  end

  def error_cd
    @error_cd
  end

  def error_msg
    @error_msg
  end

  private

    def check_errors
      if @payload['error']
        errors = @payload['error']
        Rails.logger.debug "==========GstResponse::check_errors:: The errors json is #{errors}"
        @error_cd = errors['error_cd']
        @error_msg = errors['error_msg']
      end
    end

end