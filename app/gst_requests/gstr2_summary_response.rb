class Gstr2SummaryResponse < GstResponse
  ACTION = 'RETSUM'
  
  def initialize(company, gsp, usr_ip_addr, txn, gstr2_summary, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr2_summary = gstr2_summary
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
  end

  # def payload(data)
  #   puts " The response payload is #{data.body}"
  #   #parse the payload and do processing
  #   @payload = JSON.parse data.body
  # end

  def success?
    @payload['status_cd'] == "1"
  end

  def summary
    @summary ||= decrypt_payload
  end


  def decrypt_payload
    @decrypt_payload ||= decrypt_data
    Rails.logger.debug "gstr2SummaryResponse::decrypt_payload:: The Payload is #{@decrypt_payload}"
    @decrypt_payload
  end

  def rek
    @rek ||= decrypt_rek
  end

  def ek
    @ek ||= decrypt_sek
  end

  def action
    ACTION
  end
  
  private 

    def decrypt_data
      JSON.parse(Base64.decode64(@encryption_utility.decrypt_payload(rek, @payload['data'])))
    end

    def decrypt_rek
      rek_str = @payload['rek']
      decrypt_rek = @encryption_utility.decrypt_rek(ek, rek_str)
      decrypt_rek
    end

    def decrypt_sek
      @encryption_utility.decrypt_sek(@asp.app_key, @active_session.sek)
    end

end