
require "openssl"

class CertificateNotFoundError < RuntimeError
  def initialize msg
    super msg
  end
end

class CertManager
  
  def initialize settings
    @settings = settings["certificates"]
  end
  
  def load_certs
    @certs = {}
    @settings.each_pair { |name, cert|
      type = cert[0]
      cert_file = cert[1]
      key_file = cert[2]
      
      cert = OpenSSL::X509::Certificate.new File.read cert_file
      
      case type
      when "rsa"
        key = OpenSSL::PKey::RSA.new File.read(key_file)
      when "ec"
        key = OpenSSL::PKey::EC.new File.read(key_file)
      else
        raise RuntimeError.new "Unknown certificate type: #{type}"
      end
      
      @certs[name] = [cert, key]
    }
  end
  
  # returns an cert
  def get_cert name
    return @certs[name]
  end
  
  # returns an array with certs
  def get_certs names
    res = []
    
    names.each { |certname|
      res << get_cert(certname)
    }
    
    return res
  end
  
end