
require 'socket'
require 'openssl'
require 'uri'
require 'timeout'

require_relative 'cert_manager'
require_relative 'sites_manager'
require_relative 'aliases_manager'
require_relative 'file_settings_manager'

# Generic gemini error
class GenericGeminiError < RuntimeError
end

# spec Appendix 1. Full two digit status codes
class BadRequestGemini < GenericGeminiError
end

# spec Appendix 1. Full two digit status codes
class ProxyRequestRefusedGemini < GenericGeminiError
end

# spec Appendix 1. Full two digit status codes
class NotFoundGemini < GenericGeminiError
end

# spec Appendix 1. Full two digit status codes
class GoneGemini < GenericGeminiError
end

# Main class for the gemini server
class GeminiServer

  attr_accessor :not_found_page, :client_timeout, :settings

  def initialize crtmgr, alimgr, sitmgr, filmgr
    @crtmgr = crtmgr
    @alimgr = alimgr
    @sitmgr = sitmgr
    @filmgr = filmgr

    @context = OpenSSL::SSL::SSLContext.new

    # Implement sni
    @context.servername_cb = lambda do |arg|
      name = arg[1]

      ctx = OpenSSL::SSL::SSLContext.new

      begin
        # load certificate names for alias
        certs = @alimgr.get_certs_for_alias(name, @crtmgr)
      rescue CertificateNotFoundError
        # load certificate names for default certificate
        certsname = get_setting('server', 'default_certificates')
        certs = @crtmgr.get_certs(certsname)
      end

      # add certificates with keys (of different crypto type) to context
      certs.each do |cert|
        ctx.add_certificate cert[0], cert[1]
      end
      
      set_context ctx
      
      return ctx
    end
  end

  def load_settings settings
    @settings = settings
    set_context @context
  end

  def start
    host = get_setting('server', 'host')
    port = get_setting('server', 'port')

    serv = TCPServer.new host, port
    puts "Listen at #{host} on port #{port}"
    @secure = OpenSSL::SSL::SSLServer.new(serv, @context)
  end

  def get_setting cat, sub
    @settings[cat][sub]
  end

  def set_context ctx
    # Require min tls version (spec 4.1)
    ctx.min_version = :TLS1_2
    ctx.security_level = get_setting('server', 'security_level').to_i
  end

  def listen
    loop do
      begin
        Thread.new(@secure.accept) do |conn|
          begin
            request_line = Timeout::timeout(get_setting('server', 'client_timeout')) do
              conn.gets.chomp
            end

            if request_line == ''
              raise BadRequestGemini, get_setting('messages', 'request_line_empty')
            end

            if request_line.length > 1024
              raise BadRequestGemini, get_setting('messages', 'uri_too_long')
            end

            uri = URI(request_line)

            if uri.port && uri.port != get_setting('server', 'port')
              raise ProxyRequestRefusedGemini, format(get_setting('messages', 'wrong_port'), uri.port)
            end

            if uri.scheme.nil?
              raise BadRequestGemini, get_setting('messages', 'no_scheme')
            elsif uri.scheme != 'gemini'
              raise ProxyRequestRefusedGemini, format(get_setting('messages', 'wrong_scheme'), uri.scheme)
            end

            site = uri.host
            unless @sitmgr.exist? site
              raise ProxyRequestRefusedGemini, get_setting('messages', 'domain_not_found')
            end

            root_dir = File.realpath(@sitmgr.get_root_for_site(site))
            target = "#{root_dir}/#{uri.path}"

            begin
              requested_file = File.realpath(target)
            rescue Errno::ENOENT, Errno::ENAMETOOLONG
              raise NotFoundGemini, get_setting('messages', 'not_found')
            end

            # check for path injection
            unless requested_file.start_with?(root_dir)
              raise GoneGemini, get_setting('messages', 'path_injection_message')
            end

            unless File.file? requested_file
              requested_file += "/#{@sitmgr.get_index_for_site(site)}"
            end

            # case: index file not found or access on file is denied
            unless File.readable? requested_file
              raise NotFoundGemini, get_setting('messages', 'not_found')
            end

            mime = @filmgr.get_mimetype(File.extname(requested_file))
            mime ||= get_setting('server', 'default_mimetype')

            conn.print "20 #{mime}\r\n"

            file_stream = File.new(requested_file, 'rb')
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
            conn.print "40 #{get_setting('messages', 'timeout')}\r\n"
          rescue
            warn $!
          end
          conn.close
        end
      rescue
        warn $!
      end
    end
  end

end
