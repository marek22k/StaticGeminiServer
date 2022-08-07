
require "socket"
require "openssl"
require "uri"
require "timeout"

require_relative "CertManager"
require_relative "SitesManager"
require_relative "AliasesManager"
require_relative "FileSettingsManager"

class GenericGeminiError < RuntimeError
  def initialize msg
    super msg
  end
end

class BadRequestGemini < GenericGeminiError
  def initialize msg
    super msg
  end
end

class ProxyRequestRefusedGemini < GenericGeminiError
  def initialize msg
    super msg
  end
end

class NotFoundGemini < GenericGeminiError
  def initialize msg
    super msg
  end
end

class GoneGemini < GenericGeminiError
  def initialize msg
    super msg
  end
end

class GeminiServer
  
  attr_accessor :not_found_page, :client_timeout, :settings
  
  def initialize crtmgr, alimgr, sitmgr, filmgr
    @crtmgr = crtmgr
    @alimgr = alimgr
    @sitmgr = sitmgr
    @filmgr = filmgr
    
    @context = OpenSSL::SSL::SSLContext.new
    # Require min tls version (spec 4.1)
    @context.min_version = :TLS1_2
    
    # Implement sni
    @context.servername_cb = ->(arg) {
      name = arg[1]
      
      ctx = OpenSSL::SSL::SSLContext.new
      
      begin
        # load certificate names for alias
        certs = @alimgr.get_certs_for_alias(name, @crtmgr)
      rescue CertificateNotFoundError
        # load certificate names for default certificate
        certsname = get_setting("server", "default_certificates")
        certs = @crtmgr.get_certs(certsname)
      end
      
      # add certificates with keys (of different crypto type) to context
      certs.each { |cert|
        ctx.add_certificate cert[0], cert[1]
      }
      pp ctx.cert
      
      return ctx
    }
  end
  
  def load_settings settings
    @settings = settings
  end
  
  def start
    host = get_setting("server", "host")
    port = get_setting("server", "port")
    
    serv = TCPServer.new host, port
    puts "Listen at #{host} on port #{port}"
    @secure = OpenSSL::SSL::SSLServer.new(serv, @context)
  end
  
  def get_setting cat, sub
    return @settings[cat][sub]
  end
  
  def listen log = false
    loop do
      begin
        Thread.new(@secure.accept) do |conn|
          begin
            request_line = Timeout::timeout(get_setting("server", "client_timeout")) {
              conn.gets.chomp
            }

            if request_line == ""
              raise BadRequestGemini.new get_setting("messages", "request_line_empty")
            end
            
            if request_line.length > 1024
              raise BadRequestGemini.new get_setting("messages", "uri_too_long")
            end
            
            uri = URI(request_line)
            
            if uri.port
              if uri.port != get_setting("server", "port")
                raise ProxyRequestRefusedGemini.new get_setting("messages", "wrong_port") % [uri.port]
              end
            end
       
            if uri.scheme == nil
              raise BadRequestGemini.new get_setting("messages", "no_scheme")
            elsif uri.scheme != "gemini"
              raise ProxyRequestRefusedGemini.new get_setting("messages", "wrong_scheme") % [uri.scheme]
            end

            site = uri.host
            if ! @sitmgr.exist? site
              raise ProxyRequestRefusedGemini.new get_setting("messages", "domain_not_found")
            end
            
            root_dir = File.realpath(@sitmgr.get_root_for_site(site))
            target = "#{root_dir}/#{uri.path}"
   
            begin
              requested_file = File.realpath(target)
            rescue Errno::ENOENT, Errno::ENAMETOOLONG
               raise NotFoundGemini.new get_setting("messages", "not_found")
            end
            
            # check for path injection
            if ! requested_file.start_with?(root_dir)
              raise GoneGemini.new get_setting("messages", "path_injection_message")
            end
            
            if ! File.file? requested_file
              requested_file += "/#{@sitmgr.get_index_for_site(site)}"
            end
            
            mime = @filmgr.get_mimetype(File.extname(requested_file))
            if ! mime
              # unknown file extension
              mime = get_setting("server", "default_mimetype")
            end
            
            conn.print "20 #{mime}\r\n"
            
            file_stream = File.new(requested_file, "rb")
            IO::copy_stream(file_stream, conn)
            file_stream.close
            
          rescue GoneGemini
            conn.print "52 #{$!}\r\n"
          rescue NotFoundGemini
            conn.print "51 #{$!}\r\n"
          rescue ProxyRequestRefusedGemini
            conn.print "53 #{$!}\r\n"
          rescue URI::InvalidURIError, BadRequestGemini
            conn.print "59 #{$!}\r\n"
          rescue Timeout::Error
            conn.print "40 #{get_setting("messages", "timeout")}\r\n"
          rescue
            $stderr.puts $!
          end
          conn.close
        end
      rescue
        $stderr.puts $!
      end
    end
  end
  
end
