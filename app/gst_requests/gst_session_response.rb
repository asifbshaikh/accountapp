class GstSessionResponse < GstResponse

  def initialize(company, gsp, usr_ip_addr, txn)
    super(company, gsp, usr_ip_addr, txn)
    @encryption_utility = EncryptionUtility.new
  end

  def payload(data)
    super(data)
    @start_time = Time.now
  end


  def has_errors?
  end

  def ek
    @ek ||= decrypt_sek
  end

  def session_key
    @session_key ||= @payload['sek']
  end

  def auth_token
    @auth_token ||= @payload['auth_token']
  end

  def expiry
    @expiry ||= @payload['expiry']
  end

  def start_time
    @start_time
  end

  def end_time
    @end_time ||= calc_expiry_time 
  end

  private
    def calc_expiry_time
      @start_time.advance(:minutes => 120)
    end

    def decrypt_sek
      @encryption_utility.decrypt_sek(@asp.app_key, session_key)
    end
end