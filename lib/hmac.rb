require 'openssl'
require "base64"
require 'json'


class Hmac
  def generate_signature(key, data)
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'), key, data)).strip()
    # hash  = OpenSSL::HMAC.digest('sha256', key, data)
    # puts Base64.encode64(hash)
    # hash_encoded = Base64.encode64(hash)
    # hash_encoded
  end
end