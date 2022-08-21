
require 'openssl'

# Error raised when the certificat is not found
class CertificateNotFoundError < RuntimeError
end

# Helper class for managing certificates
class CertManager

  def initialize settings
    @settings = settings['certificates']
  end

  def load_certs
    @certs = {}
    @settings.each_pair do |name, cert|
      type = cert[0]
      cert_file = cert[1]
      key_file = cert[2]

      cert = OpenSSL::X509::Certificate.new File.read cert_file

      case type
      when 'rsa'
        key = OpenSSL::PKey::RSA.new File.read(key_file)
      when 'ec'
        key = OpenSSL::PKey::EC.new File.read(key_file)
      else
        raise "Unknown certificate type: #{type}"
      end

      @certs[name] = [cert, key]
    end
  end

  # returns an cert
  def get_cert name
    @certs[name]
  end

  # returns an array with certs
  def get_certs names
    res = []

    names.each do |certname|
      res << get_cert(certname)
    end

    res
  end

end
