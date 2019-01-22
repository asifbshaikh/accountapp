require 'session_establishment_service'

class VayanaSessionEstablishmentService < SessionEstablishmentService

  def timestamp
  time = Time.now.strftime("%Y%m%d%H%M%S") 
  end


  def signature
    auth_string ="l7xx347ad87258aa48ebb61fcbdab7d19b0b:TXN789123456689:#{timestamp}:27GSPMH4602G1ZS"
    puts auth_string
    # Load PRIVATE key
    private_key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/resources/vayana/privatekey.txt"))

    # Sign our data
    signature = private_key.sign(OpenSSL::Digest::SHA256.new, auth_string)
    # puts signature

    # Our message signature that ensures that our data is signed by our private key
    Base64.encode64(signature)
    #puts Base64.encode64(signature)
  end

end
