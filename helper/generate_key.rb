
require "openssl"
require "optparse"

options = {}
OptionParser.new do |opt|
  opt.on("-t", "--type [RSA|EC]", "Sets the key type") { |o| options[:type] = o.downcase.to_sym }
  opt.on("-s", "--size [SIZE]", "For RSA keys, the key length. Common are 2048, 4096 or 8192.") { |o| options[:rsa_size] = o }
  opt.on("-c", "--curve [CURVE]", "For EC key, the curve.") { |o| options[:ec_curve] = o }
  opt.on("-o", "--output [FILE]", "File in which the key is stored. (PEM format)") { |o| options[:output] = o }
  opt.on("-lc", "Lists the available ec curves") { |o| options[:lc] = true }
end.parse!

if options[:lc]
  puts "NAME\tDESCRIPTION"
  OpenSSL::PKey::EC.builtin_curves.each { |curve|
    puts "#{curve[0]}\t#{curve[1]}"
  }
elsif options[:type]
  output_file = options[:output]
  
  if ! output_file
    raise RuntimeError, "No file was specified to save."
  end
  
  case options[:type]
  when :rsa
    puts "Generating rsa key..."
    size = options[:rsa_size].to_i
    if size < 1024
      raise RuntimeError, "The size must be greater than 1024."
    end
    key = OpenSSL::PKey::RSA.generate size
  when :ec
    puts "Generating ec key..."
    curve = options[:ec_curve]
    if ! curve
      raise RuntimeError, "No EC curve was specified."
    end
    key = OpenSSL::PKey::EC.generate curve
  else
    raise RuntimeError, "Invalid type. Can be RSA or EC."
  end
  
  File.write output_file, key.to_pem
  puts "Saved to #{output_file}"
else
  raise RuntimeError, "No arguments given. Try `-h` or `-t rsa -s 4096 -o key.pem`."
end