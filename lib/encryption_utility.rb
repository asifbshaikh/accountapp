require 'net/http'
require 'openssl'
require 'base64'
require 'aes_encrypt_decrypt'
require 'hmac'

class EncryptionUtility

  def initialize
    @asp_information = AspConfig.instance
  end

  #Naveen 4 Sep 2017 The method and process to encrypt JSON payload
  #Imp** convert the JSON into UTF-8 characterset if not this will cause problems
  #in encryption and generation of HMAC
  def encrypt_payload(ek, json_payload)
    base64_payload = Base64.strict_encode64(json_payload.force_encoding("UTF-8"))
    #Rails.logger.debug "EncryptionUtility::encrypt_payload::Base 64 payload is #{base64_payload}"
    aes_encryption = AesEncryptDecrypt.new()
    aes_encryption.encrypt(base64_payload, ek)
  end

  #Naveen 4 Sep 2017
  #Params are EK and JSON payload
  #Imp** convert the JSON into UTF-8 characterset if not this will cause problems
  #in encryption and generation of HMAC
  #1. base64 encode payload
  #2. Generate HMAC of base 64 payload using EK as key
  #3. REturn the base64 encode of the generated hmac
  def generate_hmac(key, json_payload)
    base64_payload = Base64.strict_encode64(json_payload.force_encoding("UTF-8"))
    #Rails.logger.debug "EncryptionUtility::generate_hmac::Base 64 payload is #{base64_payload}"
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'), key, base64_payload)).strip()
  end

  def decrypt_payload(key, payload)
    aes_encrypt = AesEncryptDecrypt.new()
    aes_encrypt.decrypt(payload, key)
  end

  def encrypt_app_key
    public_key_file = File.read('#{Rails.root}/resources/gstn/GSTN_private.pem');
    app_key = '9b0d686d-f4e3-4b49-a347-22440b8f';
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_string = Base64.encode64(public_key.public_encrypt(app_key))
  end

  def encrypt_otp(otp)
    otp_encryption = AesEncryptDecrypt.new()
    encrypt_otp = otp_encryption.encrypt(otp, @asp_information.app_key)
    encrypt_otp
  end

  # def encrypt_payload(key, payload)
  #   payload_encryption = AesEncryptDecrypt.new()
  #   encrypt_payload = payload_encryption.encrypt(payload, @asp_information.app_key)
  #   encrypt_payload
  # end

  #this will return me EK
  def decrypt_sek(app_key, sek)
    aes_encryption = AesEncryptDecrypt.new
    ek = aes_encryption.decrypt(sek, app_key)
  end

  def decrypt_rek(key, value)
    aes_encrypt = AesEncryptDecrypt.new()
    aes_encrypt.decrypt(value, key)
  end

end