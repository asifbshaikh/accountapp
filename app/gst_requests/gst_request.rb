class GstRequest

  def initialize(company, gsp, usr_ip_addr, txn)
    @company = company
    @gsp = gsp
    @asp = AspConfig.instance
    @usr_ip_addr = usr_ip_addr
    @txn = txn
    @headers = create_header
  end

  attr_accessor :company, :gsp, :asp, :usr_ip_addr, :txn
  
  def request_URL
  end

  def headers
    @headers ||= create_header
  end

  def add_header(key, value)
    @headers[key] = value
  end

  def add_headers(hash_obj)
    @headers.merge(hash_obj)
  end

  private

    def create_header
      Rails.logger.debug "GstRequest::create_header::BEGIN"
      {'client-secret'=> @asp.client_secret, 'clientid' => @asp.client_id, 'content-type' => @asp.content_type, 
        'ip-usr' => @usr_ip_addr, 'state-cd' => user_state_cd, 'txn' => "#{@txn}", 
        'karvyclientid' => 'profitbooks' , 'karvyclient-secret' => 'profit123$!'}
    end

    def user_state_cd
      @company.gstn_state_code
    end
end
