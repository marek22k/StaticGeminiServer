
require "openssl"
require "optparse"

options = {}
options[:dns] = []
OptionParser.new do |opt|
  opt.on("-t", "--type RSA|EC", "Sets the key type") { |o| options[:key_type] = o.downcase.to_sym }
  opt.on("-k", "--key-file FILE", "File in which the key is stored.") { |o| options[:key_file] = o }
  opt.on("-d", "--digest SHA1|SHA224|SHA256|SHA384|SHA512", "Hash function which is used to sign the certificate.") { |o| options[:digest] = o }
  opt.on("-c", "--common-name STRING", "Common name for the certificate, often the same as the host name.") { |o| options[:cn] = o }
  opt.on("-m", "--email E-MAIL", "E-mail address to be stored in the certificate.") { |o| options[:email] = o }
  opt.on("-f", "--dns FQDN", "DNS names to be specified in the certificate, often the same as the common name. More than one can be specified.") { |o| options[:dns] << o }
  opt.on("-o", "--output FILE", "File in which the certificate is stored. (PEM format)") { |o| options[:output] = o }
end.parse!

puts "Parsing arguments..."

output_file = options[:output]

if ! output_file
  raise RuntimeError, "No file was specified to save."
end

digest = options[:digest]

if ! digest
  raise RuntimeError, "A hash function must be specified to sign the certificate."
end

common_name = options[:cn]

if ! common_name
  raise RuntimeError, "A common name must be specified."
end

email = options[:email]

if ! email
  raise RuntimeError, "An e-mail must be specified."
end

dns_ary = options[:dns]

if ! dns_ary
  raise RuntimeError, "A DNS name must be specified."
end

dns = "DNS:".concat dns_ary.sort.join(", DNS:")

key_file = options[:key_file]
key_type = options[:key_type]

key_pem = File.read key_file
case key_type
when :ec
  key = OpenSSL::PKey::EC.new key_pem
when :rsa
  key = OpenSSL::PKey::RSA.new key_pem
else
  raise RuntimeError, "The key type is unknown."
end

# https://github.com/ruby/openssl/issues/29#issuecomment-149799052
def ec_public_key k
    point = k.public_key
    pub = OpenSSL::PKey::EC.new point.group
    pub.public_key = point
    return pub
end

puts "Generating certificate..."

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = Random.rand(2**16 - 2) + 1

cert.subject = OpenSSL::X509::Name.new [["CN", common_name], ["emailAddress", email]]
cert.issuer = cert.subject  # self-signed certificate

case key_type
when :ec
  cert.public_key = ec_public_key key
when :rsa
  cert.public_key = key.public_key
end

cert.not_before = Time.now

cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = ef.subject_certificate

cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
cert.add_extension(ef.create_extension("basicConstraints", "CA:FALSE", true))
cert.add_extension(ef.create_extension("subjectAltName", dns, false))
cert.add_extension(ef.create_extension("keyUsage", "digitalSignature, nonRepudiation, keyEncipherment, keyAgreement", false))
cert.add_extension(ef.create_extension("extendedKeyUsage", "serverAuth", false))

cert.sign(key, OpenSSL::Digest.new(digest))

File.write output_file, cert.to_pem
puts "Saved to file #{output_file}"