class Gstr2StatusResponse < GstResponse

  ACTION = 'RETSTATUS'
  
  def initialize(company, gsp, usr_ip_addr, txn, gstr_two, active_session)
    super(company, gsp, usr_ip_addr, txn)
    @gstr_two = gstr_two
    @active_session = active_session
    @encryption_utility = EncryptionUtility.new
  end

  def success?
    @payload['status_cd'] == "1"
  end

  def hash_payload
    @hash_payload ||= JSON.parse(json_payload)
  end

  def json_payload
    @json_payload ||= decrypt_payload
  end

  def decrypt_payload
    @decrypt_payload ||= decrypt_data
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
      (Base64.decode64(@encryption_utility.decrypt_payload(rek, @payload['data'])))
    end

    def decrypt_rek
      rek_str = @payload['rek']
      Rails.logger.debug "Gstr2SaveResponse::decrypt_rek:: the rek_str is #{rek_str}"
      decrypt_rek = @encryption_utility.decrypt_rek(ek, rek_str)
      Rails.logger.debug "Gstr2SaveResponse::decrypt_rek:: the decrypted rek is #{decrypt_rek}"
      decrypt_rek
    end

    def decrypt_sek
      @encryption_utility.decrypt_sek(@asp.app_key, @active_session.sek)
    end

end