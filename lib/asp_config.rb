
require 'singleton'
class AspConfig
  include Singleton


  def initialize
    gstconfig = YAML.load(File.read('config/gstn_credentials.yml'))
    @client_secret= gstconfig['Gstcredentials']['client-secret']
    @client_id = gstconfig['Gstcredentials']['client-id']
    @content_type = gstconfig['Gstcredentials']['content-type']
    @app_key =  gstconfig['Gstcredentials']['app-key']
    @encrypted_app_key = gstconfig['Gstcredentials']['encrypted-app-key']
  end


 
def client_secret
   @client_secret
end


def client_id
   @client_id

end

def content_type
  @content_type
end

def app_key
  @app_key
end

def encrypted_app_key
  @encrypted_app_key
end



end
